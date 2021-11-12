//
//  ContentView.swift
//  SayMyName
//
//  Created by Brothersoft on 10/14/21.
//

import SwiftUI
import Speech

//MARK: - Main structures

struct ContentView: View {
    @State private var animals = [
        Animal(name: "Bear", id: 0),
        Animal(name: "Bird", id: 1),
        Animal(name: "Cat", id: 2),
        Animal(name: "Dog", id: 3),
        Animal(name: "Elephant", id: 4),
        Animal(name: "Panda", id: 5),
        Animal(name: "Pig", id: 6),
        Animal(name: "Rabbit", id: 7),
        Animal(name: "Rat", id: 8),
        Animal(name: "Wolf", id: 9)]
    @State private var speechText = ""
    
    var body: some View {
        GeometryReader { geometry in
        VStack {
            Controller(speechValue: $speechText)
            ZStack {
                Text("Congratulations, you have succeeded!")
                    .bold()
                    .font(.system(size: 40))
                ForEach(self.animals, id: \.self) { animal in
                    Card(imageName: animal.getName(), speechText: $speechText, onRemove: { animal in
                        if animal == animals.last?.getName() {
                            animals.removeLast()
                        }
                    })
                    .frame(width: self.getCardWidth(geometry, id: animal.getId()), height: 400)
                    .offset(x: 0, y: self.getCardOffset(geometry, id: animal.getId()))
                }
            }
        }.background(Color.yellow)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//MARK: - Other structures

struct Card: View {
    var imageName: String
    @State private var translation: CGSize = .zero
    @State private var backgroundColor = Color.white
    @Binding var getSpeechText: String
    private var onRemove: (_ imageName: String) -> Void
    
    init(imageName: String, speechText: Binding<String>, onRemove: @escaping (_ imageName: String) -> Void) {
        self.imageName = imageName
        self._getSpeechText = speechText
        self.onRemove = onRemove
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Image(imageName)
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    .aspectRatio(contentMode: .fill)
                Text("What is this animal?")
                    .bold()
                    .frame(width: geometry.size.width, height: 50, alignment: .center)
                    .font(.system(size: 35))
                Text(getSpeechText)
                    .underline()
                    .bold()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.1, alignment: .center)
                    .font(.system(size: 35))
                    .padding(.top, 50)
                    .foregroundColor(.black)
                    .onChange(of: getSpeechText, perform: { value in
                        if getSpeechText == imageName {
                            backgroundColor = Color.green
                            withAnimation(.linear(duration: 2)) { self.translation = CGSize(width: -400, height: self.translation.height) }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                getSpeechText = ""
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.onRemove(self.imageName)
                            }
                        }
                    })
            }
            .padding(.bottom)
            .background(backgroundColor)
            .cornerRadius(5)
            .shadow(color: .gray,radius: 7)
            .offset(x: self.translation.width, y: self.translation.height)
        }
    }
}

struct Controller: View {
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    @State private var request: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var imageName = "microphoneOff"
    @State private var isMicrophoneOff = true
    @Binding var speechValue: String
    
    var body: some View {
        HStack(spacing: 60) {
            Text("Controller")
                .bold()
                .font(.system(size: 40))
            Image(imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .onTapGesture {
                    toggleMicrophone()
                }
        }
        .frame(width: UIScreen.main.bounds.width, height: 90, alignment: .center)
    }
}

//MARK: - Private methods

private extension Controller {
    func toggleMicrophone() {
        if isMicrophoneOff {
            microphoneOn()
        }
         else {
            microphoneOff()
        }
    }
    
    private func microphoneOff() {
        recognitionTask?.finish()
        request?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        imageName = "microphoneOff"
        isMicrophoneOff = true
    }
    
    private func microphoneOn() {
        imageName = "microphoneOn"
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
        }
        guard let myRecognizer = speechRecognizer else { return }
        if !myRecognizer.isAvailable {
            return
        }
        request = SFSpeechAudioBufferRecognitionRequest()
        recognitionTask = myRecognizer.recognitionTask(with: request!, resultHandler: { (result, error) in
            if let result = result {
                if result.isFinal {
                    audioEngine.stop()
                    request = nil
                    recognitionTask = nil
                }
                let bestString = result.bestTranscription.formattedString
                if let lastWord = bestString.capitalized.lastWord() {
                    speechValue = lastWord
                }
            } else if let error = error {
                print(error)
            }
        })
        isMicrophoneOff = false
    }
}

private extension ContentView {
    private func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
            return  CGFloat(animals.count - 1 - id) * 10
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        let offset: CGFloat = CGFloat(animals.count - 1 - id) * 10
        return geometry.size.width - offset
    }
}

