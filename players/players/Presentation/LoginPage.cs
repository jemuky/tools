namespace players.Presentation;

public sealed partial class LoginPage : Page {
    public LoginPage() {
        this.DataContext<LoginViewModel>((page, vm) => page
            // .NavigationCacheMode(NavigationCacheMode.Required)
            .Background(Theme.Brushes.Background.Default)
            .Content(new Grid()
                .SafeArea(SafeArea.InsetMask.VisibleBounds)
                .RowDefinitions("Auto,*")
                .Children(
                    // new NavigationBar().Content(() => vm.Title),
                    new StackPanel()
                        .Grid(row: 1)
                        .HorizontalAlignment(HorizontalAlignment.Center)
                        .VerticalAlignment(VerticalAlignment.Center)
                        .Width(200)
                        .Spacing(16)
                        .Children(
                            new TextBox()
                                .Text(x => x.Binding(() => vm.Username).TwoWay())
                                .PlaceholderText("Username")
                                .HorizontalAlignment(HorizontalAlignment.Stretch),
                            new PasswordBox()
                                .Password(x => x.Binding(() => vm.Password).TwoWay())
                                .PlaceholderText("Password")
                                .HorizontalAlignment(HorizontalAlignment.Stretch),
                            new Button()
                                .Content("Login")
                                .HorizontalAlignment(HorizontalAlignment.Stretch)
                                .Command(() => vm.Login)
                        ))));
    }
}
