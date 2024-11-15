namespace players.Business;

using players.Business.Models;

public interface IYoutubeService {
    Task<YoutubeVideoSet> SearchVideos(string searchQuery, string nextPageToken, uint maxResult, CancellationToken ct);
}
