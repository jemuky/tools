using Serilog;

namespace players.Presentation;

public sealed partial class MainPage : Page {
    public MainPage() {
        Console.WriteLine($"------------------Main---------------------");
        Log.Debug($"------------------Main---------------------");
        Log.Information($"------------------Main---------------------");
        Log.Warning($"------------------Main---------------------");
        Log.Error($"------------------Main---------------------");
        this.DataContext<MainViewModel>((page, vm) => page
            .NavigationCacheMode(NavigationCacheMode.Required)
            .Background(Theme.Brushes.Background.Default)
            .Content(new Grid()
                .SafeArea(SafeArea.InsetMask.VisibleBounds)
                .RowDefinitions("Auto,*")
                .Children(
                    new NavigationBar().Content(() => vm.Title),
                    new StackPanel()
                        .Grid(row: 1)
                        .HorizontalAlignment(HorizontalAlignment.Center)
                        .VerticalAlignment(VerticalAlignment.Center)
                        .Spacing(16)
                        .Children(
                            new TextBox()
                                .Text(x => x.Binding(() => vm.Name).Mode(BindingMode.TwoWay))
                                .PlaceholderText("Enter your name:"),
                            new Button()
                                .Content("Go to Second Page")
                                .AutomationProperties(automationId: "SecondPageButton")
                                .Command(() => vm.GoToSecond),
                            new Button()
                                .Content("Go to Tube Page")
                                .AutomationProperties(automationId: "TubePageButton")
                                .Command(() => vm.GoToTube),
                            new Button().Content("Logout").Command(() => vm.Logout),
                            new TextBlock()
                                .Text(x => x.Binding(() => vm.Count).Mode(BindingMode.OneTime)),
                            new Button().Content("add one").Command(() => vm.Counter)
                        ))));
    }
}
