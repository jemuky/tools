// See https://aka.ms/new-console-template for more information
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;


// 配置 Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .WriteTo.File("log.txt", rollingInterval: RollingInterval.Day) // 写入文件
    .CreateLogger();


Log.Debug("Hello, World!");
// 注册编码提供程序，否则某些响应貌似返回gbk，导致ReadAsStringAsync失败
Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

// Stopwatch watch = new();
// 创建主机
var host = Host.CreateDefaultBuilder(args).ConfigureAppConfiguration((ctx, config) => {
    // 移除默认的 appsettings.json
    // config.Sources.Clear();
    // 添加自定义的配置文件
    // config.AddJsonFile("customsettings.json", optional: false, reloadOnChange: true);
}).ConfigureServices((ctx, config) => { }).Build();

// 获取 IConfiguration 实例
var configuration = host.Services.GetRequiredService<IConfiguration>();

// 访问配置项
var setting1 = configuration["Logging:LogLevel:Microsoft"];
var setting2 = configuration["ConnectionStrings:DefaultConnection"];
Log.Debug($"Setting1: {setting1}, setting2: {setting2}");

// 当前时间秒值
static long curTime() {
    return (long)(DateTime.Now.ToUniversalTime() - new DateTime(1970, 1, 1)).TotalSeconds;
}

static Dictionary<string, string> decodeWXRsp(string rspBody) {
    Dictionary<string, string> result = [];
    var regex = new Regex(@"([a-zA-Z_][a-zA-Z0-9_.]*)\s*=\s*(['\""]?)(.*?)\2(?=\s*;|$)", RegexOptions.Singleline);
    var matches = regex.Matches(rspBody);
    foreach (Match match in matches) {
        if (match.Groups.Count == 4) {
            string key = match.Groups[1].Value;
            string value = match.Groups[3].Value;

            result[key] = value;
        }
    }
    return result;
}

// 参见 https://www.cnblogs.com/chenxizhaolu/p/8426286.html
using (HttpClient client = new()) {
    // 1. 登陆。获取cookie
    HttpResponseMessage rsp = await client.GetAsync("https://wx.qq.com");
    rsp.EnsureSuccessStatusCode();
    var rspBody = await rsp.Content.ReadAsStringAsync();

    var cookie = string.Join(',', rsp.Headers.GetValues("Set-Cookie"));
    Log.Information($"1. cookie: rspBody: html没必要打印，长度: {rspBody.Length}, cookie: {cookie}");

    client.DefaultRequestHeaders.Add("session", "");
    client.DefaultRequestHeaders.Add("cookie", cookie);
    client.DefaultRequestHeaders.Add("headers", "");
    // 2. 二维码uuid
    rsp = await client.GetAsync($"https://wx.qq.com/jslogin?appid=wx782c26e4c19acffb&fun=new&lang=en_US&_={curTime()}&redirect_uri=https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage");
    rsp.EnsureSuccessStatusCode();
    rspBody = await rsp.Content.ReadAsStringAsync();
    Log.Information($"2. 二维码uuid: rspBody: {rspBody}, headers: {rsp.Headers}");

    if (!decodeWXRsp(rspBody).TryGetValue("window.QRLogin.uuid", out string? uuid)) {
        Log.Error($"没获取到uuid, rsp={rspBody}");
        return;
    }
    Log.Information($"获取到了uuid({uuid})");

    // 3. 下载和展示二维码
    rsp = await client.GetAsync($"https://wx.qq.com/qrcode/{uuid}");
    rsp.EnsureSuccessStatusCode();
    byte[] qrcode = await rsp.Content.ReadAsByteArrayAsync();
    Log.Information($"3. 二维码: rspBody: {qrcode.Length}, headers: {rsp.Headers}");
    // 二维码
    try {
        await File.WriteAllBytesAsync("qrcode.jpg", qrcode);
    } catch (Exception e) {
        Log.Error($"write qrcode failed, e={e}");
        return;
    }

    // 4. 扫码和确认
    var now = curTime();
    rsp = await client.GetAsync($"https://wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid={uuid}&r={now / 1524}&_={now}");
    rsp.EnsureSuccessStatusCode();
    rspBody = await rsp.Content.ReadAsStringAsync();
    // rspBody: window.code=201;window.userAvatar = 'xxxxx';
    Console.WriteLine($"4. 扫码: headers: {rsp.Headers}");
    if (!decodeWXRsp(rspBody).TryGetValue("window.userAvatar", out string? userAvatar)) {
        Log.Error($"没获取到头像信息, rsp={rspBody}");
        return;
    }
    try {
        await File.WriteAllBytesAsync("user_avatar.jpg", Convert.FromBase64String(userAvatar.Replace("data:img/jpg;base64,", null)));
    } catch (Exception e) {
        Log.Error($"write userAvatar failed, userAvatar={userAvatar}, e={e}");
        return;
    }

    // 5. 再请求一次，用来确认登录
    now = curTime();
    rsp = await client.GetAsync($"https://wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid={uuid}&r={now / 1524}&_={now}");
    rsp.EnsureSuccessStatusCode();
    rspBody = await rsp.Content.ReadAsStringAsync();
    // rspBody: window.code=200;window.redirect_uri = 'xxxxx';
    Log.Information($"5. 确认扫码: rspBody: {rspBody}, headers: {rsp.Headers}");
    if (!decodeWXRsp(rspBody).TryGetValue("window.redirect_uri", out string? redirectUri)) {
        Log.Error($"没获取到window.redirect_uri, rsp={rspBody}");
        return;
    }

    // 6. 初始化页面、获取登录信息
    rsp = await client.GetAsync(redirectUri);
    rsp.EnsureSuccessStatusCode();
    rspBody = await rsp.Content.ReadAsStringAsync();
    // rspBody: window.code=200;window.redirect_uri = 'xxxxx';
    Log.Information($"6. 转发页面: rspBody: {rspBody}, headers: {rsp.Headers}");
}

await Log.CloseAndFlushAsync();

// host.Run();
