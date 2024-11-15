namespace players.Presentation;

public class TempDataContext {
    public bool IsDark { get; set; }
    public ICommand? InputCommand { get; set; }
    public Calculator Calculator { get; } = new Calculator();
}
