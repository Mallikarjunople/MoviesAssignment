### 1. Clone the repository
```git clone https://github.com/yourusername/TMDbMovieApp.git```

### 2. Add your TMDb API Key(Already added in source code)

### 3. Dependencies

No external dependencies are required.
The app uses:
- UIKit for UI
- URLSession with async/await for API calls

### 4. Build & Run

- Open TMDbMovieApp.xcodeproj in Xcode
- Select the iPhone Simulator
- Press Cmd + R to build and run the app

## Implemented Features

### Movies List (Home)
- Displays popular movies with:
Poster image
Title
Rating
Duration (if available)

### Search

- Search movies by title using TMDb’s search endpoint
- Uses debounce to reduce unnecessary network calls
  
### Movie Details
- Trailer video using AVPlayerViewController
- Title, overview, genres, rating, and duration
- Two-section layout using UICollectionViewDiffableDataSource

## Favorites
- Mark/unmark a movie as favorite from both:
- Favorites are persisted using UserDefaults and restored on app relaunch

#### Known Limitations
- No pagination implemented for popular movies
- No offline storage or caching of movie data
- Trailer playback may fail if YouTube video is unavailable
