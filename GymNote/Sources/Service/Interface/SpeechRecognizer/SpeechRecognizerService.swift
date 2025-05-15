//
//  SpeechRecognizerService.swift
//  GymNote
//
//  Created by Lubos Lehota on 13/02/2025.
//

import Dependencies
import Foundation
import AVFoundation
import Speech
import SwiftUI

// TODO: this should be domain independent
public enum RecognizerError: Error {
  case nilRecognizer
  case notAuthorizedToRecognize
  case notPermittedToRecord
  case recognizerIsUnavailable
  case unknown(String)
}

public struct SpeechRecognizerService {
  public var recognizeText: () async -> Result<String, RecognizerError>
  public var stopRecognizing: () async -> Void

  public init(recognizeText: @escaping () async -> Result<String, RecognizerError>, stopRecognizing: @escaping () async -> Void) {
    self.recognizeText = recognizeText
    self.stopRecognizing = stopRecognizing
  }
}

extension DependencyValues {
  public var speechRecognizerService: SpeechRecognizerService {
    get { self[SpeechRecognizerService.self] }
    set { self[SpeechRecognizerService.self] = newValue }
  }
}

extension SpeechRecognizerService: TestDependencyKey {
  public static var testValue: SpeechRecognizerService {
    // TODO: make a proper testing value
    .init(recognizeText: { .success("") }, stopRecognizing: {})
  }
}
