using System.Diagnostics;
using Microsoft.AspNetCore.Mvc.Diagnostics;
using Microsoft.AspNetCore.Mvc.Filters;

namespace cs_webtools {
    public class MyFilter : ActionFilterAttribute {
        public override void OnActionExecuting(ActionExecutingContext ctx) {
            string path = ctx.HttpContext.Request.Path;
            Console.WriteLine($"before path: {path}");
        }

        public override void OnActionExecuted(ActionExecutedContext context) {
            Console.WriteLine("after");
        }
    }
}