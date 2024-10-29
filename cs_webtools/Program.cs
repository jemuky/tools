using System.Globalization;
using System.Reflection;
using System.Resources;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

[assembly: ApiController]

ResourceManager rm = new("cs_webtools.Res", Assembly.GetExecutingAssembly());
Thread.CurrentThread.CurrentCulture = new CultureInfo("en-us");
Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");
// 根据当前默认区域获取资源字符串
Console.WriteLine(rm.GetString("Hello"));
// 获取区域为"zh-cn"的资源字符串
Console.WriteLine(rm.GetString("Hello", new CultureInfo("zh-cn")));
// 获取区域为"en-us"的资源字符串
Console.WriteLine(rm.GetString("Hello", new CultureInfo("en-us")));

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
// 注册拦截器
builder.Services.AddControllersWithViews(opts => {
    opts.Filters.Add<cs_webtools.MyFilter>();
});
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options => {
        // To preserve the default behavior, capture the original delegate to call later.
        var builtInFactory = options.InvalidModelStateResponseFactory;
        Console.WriteLine($"factoryName: {builtInFactory.GetType().Name}");

        options.InvalidModelStateResponseFactory = context => {
            var logger = context.HttpContext.RequestServices
                                .GetRequiredService<ILogger<Program>>();

            // Perform logging here.
            // ...

            // Invoke the default behavior, which produces a ValidationProblemDetails
            // response.
            // To produce a custom response, return a different implementation of 
            // IActionResult instead.
            return builtInFactory(context);
        };
        options.SuppressConsumesConstraintForFormFileParameters = true;
        options.SuppressInferBindingSourcesForParameters = true;
        options.SuppressModelStateInvalidFilter = true;
        options.SuppressMapClientErrors = true;
        options.ClientErrorMapping[StatusCodes.Status404NotFound].Link =
            "https://httpstatuses.com/404";
    });


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment()) {
    app.UseSwagger();
    app.UseSwaggerUI();
}
// 在异常时捕获
app.UseExceptionHandler("/error");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

var summaries = new[] {
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () => {
    var forecast = Enumerable.Range(1, 5).Select(index => {
        return new WeatherForecast(
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        );
    }).ToArray();
    // throw new EntryPointNotFoundException("abc");
    return forecast;
}).WithName("GetWeatherForecast").WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary) {
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
