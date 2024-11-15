namespace players.Presentation;

public partial record TubeModel {
    private static readonly string _tubeKey = "AIzaSyDWE-3Ac290uBZkT-9a8Bgb1V-2Z8TVMsI";

    public TubeModel() {
        Title = "Tube";
    }

    public string? Title { get; }

}
