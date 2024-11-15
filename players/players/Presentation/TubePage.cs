namespace players.Presentation;


public sealed partial class TubePage : Page {
    public TubePage() {
        this.DataContext<TubeViewModel>(
            (page, vm) =>
            page
            .NavigationCacheMode(NavigationCacheMode.Required)
            .Background(Theme.Brushes.Background.Default)
            .Content(
                new Grid()
                .SafeArea(SafeArea.InsetMask.All)
                .RowDefinitions("Auto, *")
                .Children(
                    new TextBox().PlaceholderText("Search term"),
                    new ListView()
                    .Grid(row: 1)
                    .ItemsSource(new[] { "Avatar", "Titanic", "Star Wars" })
                    .ItemTemplate<string>(videoTitle => new TextBlock().Text(() => videoTitle))
                )
            )
        );
    }
}