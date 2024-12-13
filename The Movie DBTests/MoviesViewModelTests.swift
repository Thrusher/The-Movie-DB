//
//  MoviesViewModelTests.swift
//  The Movie DBTests
//
//  Created by Patryk Drozd on 12/12/2024.
//

import XCTest
@testable import The_Movie_DB

final class MoviesViewModelTests: XCTestCase {

    private var viewModel: MoviesViewModel!
    private var mockMovieService: MockMovieService!
    private var mockImageService: MockImageService!
    private var mockFavoritesManager: MockFavoritesManager!
    private var mockDelegate: MockMoviesViewModelDelegate!

    override func setUp() {
        super.setUp()
        mockMovieService = MockMovieService()
        mockImageService = MockImageService()
        mockFavoritesManager = MockFavoritesManager()
        viewModel = MoviesViewModel(
            movieService: mockMovieService,
            imageService: mockImageService,
            favoritesManager: mockFavoritesManager
        )
        mockDelegate = MockMoviesViewModelDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        viewModel = nil
        mockMovieService = nil
        mockImageService = nil
        mockDelegate = nil
        
        NotificationCenter.default.removeObserver(self, name: .favoriteStatusChanged, object: nil)
        super.tearDown()
    }

    func testFetchMoviesSuccess() {
        // Arrange
        let expectedMovies = [
            Movie(
                id: 1,
                title: "Test Movie",
                overview: "Test",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 7.5,
                voteCount: 100,
                popularity: 50.0,
                genreIDs: []
            )
        ]
        
        let expectedResponse = MovieResponse(results: expectedMovies, totalPages: 1, totalResults: 1)
        mockMovieService.mockResult = .success(expectedResponse)
        
        viewModel.delegate = mockDelegate // Ensure delegate assignment
        
        // Act
        viewModel.fetchMovies()

        let timeout: TimeInterval = 1.0
        let startTime = Date()
        while mockDelegate.updatedCellModels == nil && Date().timeIntervalSince(startTime) < timeout {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }

        // Assert
        XCTAssertEqual(mockDelegate.updatedCellModels?.count, expectedMovies.count)
        XCTAssertEqual(mockDelegate.updatedCellModels?.first?.id, expectedMovies.first?.id)
        XCTAssertFalse(mockDelegate.isLoadingState ?? true)
    }

    func testFetchMoviesFailure() {
        // Arrange
        mockMovieService.mockResult = .failure(APIError.invalidResponse)

        // Act
        viewModel.fetchMovies()
        
        let timeout: TimeInterval = 1.0
        let startTime = Date()
        while mockDelegate.updatedCellModels == nil && Date().timeIntervalSince(startTime) < timeout {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }

        // Assert
        XCTAssertEqual(mockDelegate.encounteredError, APIError.invalidResponse.errorDescription)
        XCTAssertFalse(mockDelegate.isLoadingState ?? true)
    }

    func testRefreshMovies() {
        // Arrange
        let initialMovies = [
            Movie(
                id: 1,
                title: "Initial Movie",
                overview: "Initial",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 7.5,
                voteCount: 100,
                popularity: 50.0,
                genreIDs: []
            )
        ]
        let refreshedMovies = [
            Movie(
                id: 2,
                title: "Refreshed Movie",
                overview: "Refreshed",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 8.5,
                voteCount: 200,
                popularity: 60.0,
                genreIDs: []
            )
        ]

        // Mock the initial movies response
        mockMovieService.mockResult = .success(
            MovieResponse(results: initialMovies, totalPages: 1, totalResults: 1)
        )

        // Fetch initial movies
        viewModel.fetchMovies()
        let initialTimeout = expectation(description: "Wait for initial fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initialTimeout.fulfill()
        }
        wait(for: [initialTimeout], timeout: 1.0)

        // Mock the refreshed movies response
        mockMovieService.mockResult = .success(
            MovieResponse(results: refreshedMovies, totalPages: 1, totalResults: 1)
        )

        // Act
        viewModel.refreshMovies()
        let refreshTimeout = expectation(description: "Wait for refresh fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            refreshTimeout.fulfill()
        }
        wait(for: [refreshTimeout], timeout: 1.0)

        // Assert
        XCTAssertEqual(mockDelegate.updatedCellModels?.count, refreshedMovies.count)
        XCTAssertEqual(mockDelegate.updatedCellModels?.first?.id, refreshedMovies.first?.id)
    }

    func testPagination() {
        // Arrange
        let page1Movies = [
            Movie(
                id: 1,
                title: "Page 1 Movie",
                overview: "Page 1",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 8.0,
                voteCount: 100,
                popularity: 50.0,
                genreIDs: []
            )
        ]

        let page2Movies = [
            Movie(
                id: 2,
                title: "Page 2 Movie",
                overview: "Page 2",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 7.5,
                voteCount: 80,
                popularity: 45.0,
                genreIDs: []
            )
        ]

        mockMovieService.mockResult = .success(
            MovieResponse(results: page1Movies, totalPages: 2, totalResults: 2)
        )

        // Fetch first page
        viewModel.fetchMovies()
        let firstPageTimeout = expectation(description: "Wait for first page fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            firstPageTimeout.fulfill()
        }
        wait(for: [firstPageTimeout], timeout: 1.0)

        // Change mock result for second page
        mockMovieService.mockResult = .success(
            MovieResponse(results: page2Movies, totalPages: 2, totalResults: 2)
        )

        // Act
        viewModel.fetchMovies()
        let secondPageTimeout = expectation(description: "Wait for second page fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            secondPageTimeout.fulfill()
        }
        wait(for: [secondPageTimeout], timeout: 1.0)

        // Assert
        let totalMoviesCount = page1Movies.count + page2Movies.count
        XCTAssertEqual(mockDelegate.updatedCellModels?.count, totalMoviesCount)
        XCTAssertTrue(mockDelegate.updatedCellModels?.contains(where: { $0.title == "Page 2 Movie" }) ?? false)
    }
    
    func testToggleFavoriteUpdatesState() {
        // Arrange
        let movieID = 1
        let initialMovies = [
            Movie(
                id: movieID,
                title: "Test Movie",
                overview: "Test",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 7.5,
                voteCount: 100,
                popularity: 50.0,
                genreIDs: []
            )
        ]
        let mockFavoritesManager = MockFavoritesManager()
        viewModel = MoviesViewModel(
            movieService: mockMovieService,
            imageService: mockImageService,
            favoritesManager: mockFavoritesManager
        )
        viewModel.delegate = mockDelegate
        mockMovieService.mockResult = .success(
            MovieResponse(results: initialMovies, totalPages: 1, totalResults: 1)
        )
        
        // Act
        viewModel.fetchMovies()
        mockFavoritesManager.toggleFavorite(movieID: movieID)

        // Assert
        let isFavorite = mockFavoritesManager.isFavorite(movieID: movieID)
        XCTAssertTrue(isFavorite)
    }
    
    func testFavoriteNotificationPosted() {
        // Arrange
        let movieID = 1
        let expectation = self.expectation(description: "Wait for favorite notification")
        var notificationReceived = false

        NotificationCenter.default.addObserver(forName: .favoriteStatusChanged, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let notifiedMovieID = userInfo["movieID"] as? Int else {
                XCTFail("Invalid notification userInfo")
                return
            }
            XCTAssertEqual(notifiedMovieID, movieID)
            
            if !notificationReceived {
                notificationReceived = true
                expectation.fulfill()
            }
        }
        
        let mockFavoritesManager = MockFavoritesManager()
        mockFavoritesManager.toggleFavorite(movieID: movieID)
        
        // Wait for notification
        waitForExpectations(timeout: 1.0)
    }
    
    func testFavoritesIntegrationWithViewModel() {
        // Arrange
        let movieID = 1
        let movies = [
            Movie(
                id: movieID,
                title: "Favorite Test Movie",
                overview: "Favorite Test",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-12-12",
                voteAverage: 8.0,
                voteCount: 100,
                popularity: 50.0,
                genreIDs: []
            )
        ]
        let mockFavoritesManager = MockFavoritesManager()
        viewModel = MoviesViewModel(
            movieService: mockMovieService,
            imageService: mockImageService,
            favoritesManager: mockFavoritesManager
        )
        viewModel.delegate = mockDelegate
        mockMovieService.mockResult = .success(
            MovieResponse(results: movies, totalPages: 1, totalResults: 1)
        )
        
        // Act
        viewModel.fetchMovies()
        
        // Assert
        XCTAssertFalse(mockFavoritesManager.isFavorite(movieID: movieID))
        mockFavoritesManager.toggleFavorite(movieID: movieID)
        XCTAssertTrue(mockFavoritesManager.isFavorite(movieID: movieID))
    }
}
