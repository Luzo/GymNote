//
//  SpeechRecognizerService.swift
//  GymNote
//
//  Created by Lubos Lehota on 13/02/2025.
//

import Dependencies
import Foundation
import AVFoundation
import Service
import Speech
import SwiftUI

extension SpeechRecognizerService: @retroactive DependencyKey {
  public static var liveValue: SpeechRecognizerService {
    return .init(
      recognizeText: {
        let speechRecognizer = await SpeechRecognizer.initialize()

        guard let recognizer = speechRecognizer else {
          return .failure(.nilRecognizer)
        }

        if let error = await recognizer.checkPermissions().error {
          return .failure(error)
        }

        return await recognizer.startTranscribing()
      },
      stopRecognizing: {
        let speechRecognizer = await SpeechRecognizer.initialize()
        await speechRecognizer?.stopTranscribing()
      }
    )
  }
}

// TODO: check for further optimizations of calls - this is basically v.2 from example from Apple
public actor SpeechRecognizer {
  private var audioEngine: AVAudioEngine?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private let recognizer: SFSpeechRecognizer?
  private static var sharedInstance: SpeechRecognizer?

  private init(recognizer: SFSpeechRecognizer?) {
    self.recognizer = recognizer
  }

  static func initialize() async -> SpeechRecognizer? {
    if let sharedInstance {
      return sharedInstance
    }

    let instance = Self(recognizer: SFSpeechRecognizer())
    guard await instance.recognizer != nil else {
      return nil
    }

    sharedInstance = instance
    return instance
  }

  @MainActor
  func startTranscribing() async -> Result<String, RecognizerError> {
    return await transcribe()
  }

  @MainActor
  func stopTranscribing() {
    Task {
      await reset()
    }
  }

  @MainActor
  func checkPermissions() async -> Result<Void, RecognizerError> {
    guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
      return .failure(.notAuthorizedToRecognize)
    }

    guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
      return .failure(.notPermittedToRecord)
    }

    return .success(())
  }

  private func transcribe() async -> Result<String, RecognizerError> {
    return await withCheckedContinuation { continuation in
      guard let recognizer, recognizer.isAvailable else {
        continuation.resume(returning: .failure(RecognizerError.recognizerIsUnavailable))
        return
      }

      do {
        let (audioEngine, request) = try Self.prepareEngine()
        self.audioEngine = audioEngine
        self.request = request
        self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
          self?.recognitionHandler(
            audioEngine: audioEngine,
            result: result,
            error: error,
            checkedContinuation: continuation
          )
        })
      } catch {
        self.reset()
        continuation.resume(returning: .failure(RecognizerError.recognizerIsUnavailable))
      }
    }
  }

  private func reset() {
    task?.finish()
    task = nil

    request?.endAudio()
    request = nil

    audioEngine?.stop()
    audioEngine = nil
  }

  private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
    let audioEngine = AVAudioEngine()

    let request = SFSpeechAudioBufferRecognitionRequest()
    request.taskHint = .dictation
    request.shouldReportPartialResults = false

    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    let inputNode = audioEngine.inputNode

    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode
      .installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (
        buffer: AVAudioPCMBuffer,
        when: AVAudioTime
      ) in
        request.append(buffer)
      }
    audioEngine.prepare()
    try audioEngine.start()

    return (audioEngine, request)
  }

  nonisolated private func recognitionHandler(
    audioEngine: AVAudioEngine,
    result: SFSpeechRecognitionResult?,
    error: Error?,
    checkedContinuation: CheckedContinuation<Result<String, RecognizerError>, Never>
  ) {
    let receivedFinalResult = result?.isFinal ?? false
    let receivedError = error != nil

    if receivedFinalResult || receivedError {
      audioEngine.stop()
      audioEngine.inputNode.removeTap(onBus: 0)
    }

    if let error {
      checkedContinuation.resume(returning: .failure(.unknown(error.localizedDescription)))
    }

    if let result {
      checkedContinuation.resume(returning: .success(result.bestTranscription.formattedString))
    }
  }
}

extension SFSpeechRecognizer {
  static func hasAuthorizationToRecognize() async -> Bool {
    await withCheckedContinuation { continuation in
      requestAuthorization { status in
        continuation.resume(returning: status == .authorized)
      }
    }
  }
}

extension AVAudioSession {
  func hasPermissionToRecord() async -> Bool {
    await withCheckedContinuation { continuation in
      AVAudioApplication.requestRecordPermission { authorized in
        continuation.resume(returning: authorized)
      }
    }
  }
}
