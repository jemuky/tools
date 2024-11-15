global using System.Collections.Immutable;
global using Microsoft.Extensions.DependencyInjection;
global using Microsoft.Extensions.Hosting;
global using Microsoft.Extensions.Localization;
global using Microsoft.Extensions.Logging;
global using Microsoft.Extensions.Options;
global using players.Models;
global using players.Presentation;
global using players.DataContracts;
global using players.DataContracts.Serialization;
global using players.Services.Caching;
global using players.Services.Endpoints;
global using ApplicationExecutionState = Windows.ApplicationModel.Activation.ApplicationExecutionState;
global using Color = Windows.UI.Color;
global using System.Text.Json;
global using players.Business;
global using players.Services.Models;

[assembly: Uno.Extensions.Reactive.Config.BindableGenerationTool(3)]
