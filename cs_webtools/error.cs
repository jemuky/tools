using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace cs_webtools {
    [ApiController]
    [Route("[controller]")]
    public class ErrorController : ControllerBase {
        [Route("/error")]
        public ActionResult<string> HandleError([FromServices] IHostEnvironment hostEnvironment) {
            var exceptionHandlerFeature = HttpContext.Features.Get<IExceptionHandlerFeature>()!;
            Console.WriteLine($"exception: {exceptionHandlerFeature.Error}");
            return Ok($"error: {exceptionHandlerFeature.Error.Message}");
        }
    }
}