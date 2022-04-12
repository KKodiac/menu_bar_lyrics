//
//  ContentView.swift
//  lyricsbar
//
//  Created by Sean Hong on 2022/04/08.
//

import SwiftUI
import Foundation
import Alamofire

struct Option: Hashable {
    let title: String
    let imageName: String
}

struct ContentView: View {
    @State var currentMenuOption = 0
    let options: [Option] = [
        .init(title: "Home", imageName: "house"),
        .init(title: "Lyrics", imageName: "music.note.house"),
        .init(title: "Preference", imageName: "gear"),
        .init(title: "Info", imageName: "info.circle"),
    ]
    var body: some View {
        NavigationView {
            ListView(options: options, currentMenu: $currentMenuOption)
            switch currentMenuOption {
            case 0: Text("Main View")
            case 1: LyricsView()
            case 2: Text("Preference View")
            case 3: Text("Info View")
            default: Text("Main View")
            }
        }
    }
    
}

struct ListView: View {
    let options: [Option]
    @Binding var currentMenu: Int
    var body: some View {
        VStack {
            let current = options[currentMenu]
            ForEach(options, id: \.self) { option in
                HStack {
                    Image(systemName: option.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    Text(option.title)
                        .foregroundColor(current == option ? Color.blue : Color.white)
                    Spacer()
                }
                .padding(6)
                .onTapGesture {
                    switch option.title {
                    case "Home": currentMenu = 0
                        
                    case "Lyrics": currentMenu = 1
                    case "Preference": currentMenu = 2
                    case "Info": currentMenu = 3
                    default: currentMenu = 0
                    }
                }
            }
        }
    }
}


struct LyricsView: View {
    @State var jsonData: [String] = []
    @State var artist: String = ""
    @State var title: String = ""
    var body: some View {
        VStack {
            Text(artist)
            Text(title)
        }
        .padding([.top, .leading, .trailing])
        Divider()
        ScrollView {
            VStack {
                ForEach(jsonData, id: \.self) { data in
                    Text(data)
                }
            }
        }
        .onAppear {
            currentlyPlaying()
        }
    }
    
    // MARK: Rceiving title and artist information of current music
    func currentlyPlaying() {
        // Load framework
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // Get a Swift function for MRMediaRemoteGetNowPlayingInfo
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

        // Get a Swift function for MRNowPlayingClientGetBundleIdentifier
        guard let MRNowPlayingClientGetBundleIdentifierPointer = CFBundleGetFunctionPointerForName(bundle, "MRNowPlayingClientGetBundleIdentifier" as CFString) else { return }
        typealias MRNowPlayingClientGetBundleIdentifierFunction = @convention(c) (AnyObject?) -> String
        let MRNowPlayingClientGetBundleIdentifier = unsafeBitCast(MRNowPlayingClientGetBundleIdentifierPointer, to: MRNowPlayingClientGetBundleIdentifierFunction.self)

        // Get song info
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { (information) in
            NSLog("%@", information["kMRMediaRemoteNowPlayingInfoArtist"] as! String)
            NSLog("%@", information["kMRMediaRemoteNowPlayingInfoTitle"] as! String)
            NSLog("%@", information["kMRMediaRemoteNowPlayingInfoAlbum"] as! String)
            let artwork = NSImage(data: information["kMRMediaRemoteNowPlayingInfoArtworkData"] as! Data)
            artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as! String
            title = information["kMRMediaRemoteNowPlayingInfoTitle"] as! String
            fetch(title: title, artist: artist)
        })
    }
    func fetch(title: String, artist: String?) {
        var baseURL = "http://127.0.0.1:5000/lyrics/"
        baseURL.append(contentsOf: title)
        if let artist = artist {
            baseURL.append(contentsOf: ":")
            baseURL.append(contentsOf: artist)
        }
        
        let encodedString = baseURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodedString)!
        let jsonDecoder = JSONDecoder()
        AF.request(url).responseDecodable(decoder: jsonDecoder) { (response: DataResponse<[String], AFError>) in
            if let data = response.value {
                jsonData = data
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
