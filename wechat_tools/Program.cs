// See https://aka.ms/new-console-template for more information
using System.Diagnostics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

Console.WriteLine("Hello, World!");

Stopwatch watch = new();
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
Console.WriteLine($"Setting1: {setting1}, setting2: {setting2}");

static long curTime() {
    return (long)(DateTime.Now.ToUniversalTime() - new DateTime(1970, 1, 1)).TotalSeconds;
}

// 参见 https://www.cnblogs.com/chenxizhaolu/p/8426286.html
using (HttpClient client = new()) {
    // 1. 登陆。获取cookie
    HttpResponseMessage rsp = await client.GetAsync("https://wx.qq.com");
    rsp.EnsureSuccessStatusCode();
    var rspBody = await rsp.Content.ReadAsStringAsync();

    var cookie = string.Join(',', rsp.Headers.GetValues("Set-Cookie"));
    Console.WriteLine($"rspBody: html没必要打印，长度: {rspBody.Length}, cookie: {cookie}");

    client.DefaultRequestHeaders.Add("session", "");
    client.DefaultRequestHeaders.Add("cookie", cookie);
    client.DefaultRequestHeaders.Add("headers", "");
    // 2. 二维码uuid
    rsp = await client.GetAsync($"https://wx.qq.com/jslogin?appid=wx782c26e4c19acffb&fun=new&lang=en_US&_={curTime()}&redirect_uri=https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage");
    rsp.EnsureSuccessStatusCode();
    rspBody = await rsp.Content.ReadAsStringAsync();
    Console.WriteLine($"rspBody: {rspBody}, headers: {rsp.Headers}");

    string? uuid = null;
    foreach (var item in rspBody.Split(";")) {
        var v = item.Trim();
        if (v.StartsWith("window.QRLogin.uuid")) {
            uuid = v[(v.IndexOf('=') + 1)..v.Length].Trim()[1..^1];
        }
    }
    if (uuid == null) {
        Console.WriteLine("没获取到uuid");
        return;
    }
    Console.WriteLine($"获取到了uuid({uuid})");

    // 3. 下载和展示二维码
    rsp = await client.GetAsync($"https://wx.qq.com/qrcode/{uuid}");
    rsp.EnsureSuccessStatusCode();
    byte[] qrcode = await rsp.Content.ReadAsByteArrayAsync();
    Console.WriteLine($"rspBody: {qrcode.Length}, headers: {rsp.Headers}");
    await File.WriteAllBytesAsync("qrcode.jpg", qrcode);

    // 4. 扫码和确认
    var now = curTime();
    rsp = await client.GetAsync($"https://wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid={uuid}&r={now / 1524}&_={now}&tip=0");
    rsp.EnsureSuccessStatusCode();
    rspBody = await rsp.Content.ReadAsStringAsync();
    // rspBody: window.code=201;window.userAvatar = 'xxxxx';(如果返回200还有redirect_uri)
    Console.WriteLine($"4. 扫码和确认: rspBody: {rspBody}, headers: {rsp.Headers}");
}

// host.Run();
