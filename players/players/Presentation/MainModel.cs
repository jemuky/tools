using System.Globalization;

namespace players.Presentation;

public partial record MainModel {
    private INavigator _navigator;

    public MainModel(
        IStringLocalizer localizer,
        IOptions<AppConfig> appInfo,
        IAuthenticationService authentication,
        INavigator navigator
    ) {
        _navigator = navigator;
        _authentication = authentication;
        Title = "Main";
        Title += $" - {localizer["ApplicationName"]}";
        Title += $" - {appInfo?.Value?.Environment}";
    }


    public string? Title { get; }

    public IState<string> Name => State<string>.Value(this, () => string.Empty);
    public IState<uint> Count => State<uint>.Value(this, () => 0);

    public IFeed<string> CounterText => Count.Select(_currentCount => _currentCount switch {
        0 => "Press Me",
        1 => "Pressed Once!",
        _ => $"Pressed {_currentCount} times!"
    });

    public async Task Counter(CancellationToken ct) {
        await Count.Update(x => ++x, ct);
    }

    public async Task GoToSecond() {
        var name = await Name;
        await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name!));
    }
    public async Task GoToTube() {
        var name = await Name;
        await _navigator.NavigateViewModelAsync<TubeModel>(this, data: new Entity(name!));
    }

    public async ValueTask Logout(CancellationToken token) {
        await _authentication.LogoutAsync(token);
    }

    private IAuthenticationService _authentication;
}
