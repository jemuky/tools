using Microsoft.AspNetCore.Mvc;

namespace cs_webtools {
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase {
        [HttpGet("attribute")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public ActionResult GetWithAttribute([FromServices] DateTime dateTime)
                                                        => Ok(DateTime.Now);

        [Route("noAttribute")]
        [HttpGet("get")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public IActionResult Get(DateTime dateTime) => Ok(DateTime.Now.ToString());

        [HttpGet("Throw")]
        public IActionResult Throw() => throw new Exception("Sample exception.");
    }
}