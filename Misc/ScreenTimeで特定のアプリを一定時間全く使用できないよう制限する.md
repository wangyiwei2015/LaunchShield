# SwiftUI-ScreenTimeAPIで特定のアプリを一定時間全く使用できないよう制限する

Last updated at 2023-09-27Posted at 2023-09-27

本記事ではScreenTimeAPIを用いて、他のアプリの使用を制限する方法を紹介します。

## はじめに

作業をしている途中に、つい息をするようにXを開いてしまい、集中が途切れてしまうことは誰にでもあると思います。
AppleにはScreenTimeAPIという機能が用意されており、他のアプリを制限できるようカスタマイズすることが可能です。

## ScreenTimeAPIとは

WWDC2021にはScreenTimeAPIが発表され、`FamilyControls`、`ManagedSettings`、`DeviceActivity`という3つの新しいフレームワークが導入されました。

- **Family Controls**
  ScreenTimeAPIへのアクセスを認証。アプリやウェブサイトを識別するために使われる透過トークンを提供して、ユーザープライバシーを保護する。
- **ManagedSettings**
  ScreenTimeで設定可能な制限を適用し、アプリの使用制限や、Webサイトのフィルタリング等の、アクティビティを制限すること可能。

今回は上記2つのフレームワークを使用し、アプリの使用を制限してみます。

## デモ

使用を制限するアプリと制限時間を設定し、制限開始をすると制限時間内はアプリの制限を解除することができない仕様になります。(残り時間が0になるまで、制御停止ボタンが押せない)

## 実装

#### 1. FamilyControlsをアプリに追加する

- Apple DeveloperのProfileの設定欄にあるAdditional Capabilitiesで、FamilyControlsにチェックを入れる
- Xcodeの`+Cabability`の箇所から、FamilyControlsを追加する

注意
`FamilyControlsを使用するアプリをTestFlight、またはAppStoreで公開するには、[こちら](https://developer.apple.com/contact/request/family-controls-distribution)からAppleに許可をリクエストする必要があるそうです。`

#### 2. FamilyControlsの承認をリクエストする

```swift
import SwiftUI
import FamilyControls

@main
struct ScreenTimeSamplesApp: App {
    
    let center = AuthorizationCenter.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            try await center.requestAuthorization(for: .individual)
                        } catch {
                            // Handle the error here.
                        }
                    }
                }
        }
    }
}
```

#### 3. `familyActivityPicker`を実装する

アプリ、カテゴリを指定するPickerViewを設定します。

```swift
import SwiftUI

struct ContentView: View {

    @StateObject var viewModel: ContentViewModel
    @State private var isPresented = false    

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Text("選択する")
        }
        .familyActivityPicker(
            isPresented: $isPresented, 
            selection: $viewModel.selection
        )
    }
}
```

#### 4. `FamilyActivityPicker`で選択したアプリ、カテゴリーのTokenを`ManagedSettingsStore`で設定する

選択したアプリ、カテゴリーのTokenを`shield`プロパティにセットすることで、使用を制限することができます。`nil`をセットすれば、制限を解除することができます。

```swift
func startBlocking() {
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name)
    store.application.denyAppRemoval = true
    store.shield.applicationCategories = .specific(selection.categoryTokens)
    store.shield.applications = selection.applicationTokens
}

func stopBlocking() {
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name)
    store.shield.applications = nil
    store.shield.applicationCategories = nil
    store.clearAllSettings()
}
```

#### Q1: アプリを削除すれば、制御を解除することができるのでは？

A1: `static let denyAppRemoval: SettingMetadata<Bool>`を指定することで、アプリの削除を防止することができます。

```swift
let store = ManagedSettingsStore(named: ManagedSettingsStore.Name)
store.application.denyAppRemoval = true
```

これにより、アラート内の「アプリを削除する」の選択肢が表示されなくなり、制御を設定しているアプリの削除を防ぐことが可能です。

注意
`このプロパティを設定すると、使用制限をかけているアプリ以外もアンインストールが制限されます。`

#### Q2: アプリのアイコンはどう取得するのか？

A2: ユーザーが選択したアプリやカテゴリのアイコンを表示するには、`ApplicationToken`、`ActivityCategoryToken`、または`WebDomainToken`のいずれかを使用して`Label`インスタンスを生成することで実現できます。

```swift
FamilyActivityPicker(selection: $selection)
if let applicationToken = selection.applicationTokens.first {
    Label(applicationToken)
        .labelStyle(.iconOnly)
}
```

## まとめ

今回は`ManagedSettings`を使用してアプリの制限だけを試してみましたが、`DeviceActivity`も使用すればアプリの使用状況を監視することもできるようになるので、いつか試してみたいと思います。



ref



https://www.jianshu.com/p/8bf9ef5b2967

https://juejin.cn/post/7233809309150216253

