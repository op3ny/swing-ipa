import Combine
import Foundation
import Observation

@MainActor
final class PlayerStore: ObservableObject {
    static let shared = PlayerStore()

    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var progress: TimeInterval = 0
    @Published var seekRevision: Int = 0
    @Published var shuffleOn: Bool = false
    @Published var loopMode: AudioPlayer.LoopMode = .off
    @Published var autoplayOn: Bool = false
    @Published var queueTracks: [Track] = []
    @Published var queueIndex: Int = 0
    @Published var autoMixOn: Bool = false

    private var cancellables: Set<AnyCancellable> = []
    private let player = AudioPlayer.shared

    private init() {
        player.$current
            .receive(on: RunLoop.main)
            .sink { [weak self] track in
                guard let self else { return }
                if self.currentSong?.trackhash != track?.trackhash {
                    self.seekRevision &+= 1
                }
                self.currentSong = track
            }
            .store(in: &cancellables)

        player.$shuffle
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.shuffleOn = $0 }
            .store(in: &cancellables)

        player.$loop
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.loopMode = $0 }
            .store(in: &cancellables)

        player.$queue
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.queueTracks = $0 }
            .store(in: &cancellables)

        player.$index
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.queueIndex = $0 }
            .store(in: &cancellables)

        player.$autoplay
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.autoplayOn = $0 }
            .store(in: &cancellables)

        player.$crossfadeDuration
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.autoMixOn = $0 > 0 }
            .store(in: &cancellables)

        player.$playing
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.isPlaying = $0 }
            .store(in: &cancellables)

        player.$time
            .receive(on: RunLoop.main)
            .sink { [weak self] time in
                guard let self else { return }
                if abs(time - self.progress) > 1.5 {
                    self.seekRevision &+= 1
                    self.progress = time
                    return
                }
                if abs(time - self.progress) >= 0.25 {
                    self.progress = time
                }
            }
            .store(in: &cancellables)
    }

    func estimatedProgress(at date: Date = Date()) -> TimeInterval {
        player.smoothTime(at: date)
    }

    func seek(to time: TimeInterval) {
        player.seek(time)
        seekRevision &+= 1
    }
}
