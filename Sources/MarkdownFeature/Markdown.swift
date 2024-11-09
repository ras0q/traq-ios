import MarkdownUI
import RegexBuilder
import SwiftUI
import TraqAPI

package struct Markdown: View {
    package let raw: String
    package let stamps: [Components.Schemas.StampWithThumbnail]

    package init(_ raw: String, stamps: [Components.Schemas.StampWithThumbnail]) {
        self.raw = raw
        self.stamps = stamps
    }

    package var markdown: String {
        let fileID = Reference(Substring.self)

        var replaced = raw
        // image files
        replaced.replace(/(?<url>https:\/\/.+\/files\/(?<fileId>[0-9a-f-]+))/) { match in
            guard let url = URL(string: String(match.url)), url.host() == traqServerURL.host() else {
                return match.url
            }
            return "![](\(traqServerURL.appending(path: "/files/\(match.fileId)/thumbnail")))"
        }
        // stamps
        replaced.replace(/(?<raw>:(?<name>[@0-9a-zA-Z_-]+)(\.[a-z-]+)*:)/) { match in
            let name = String(match.name)
            if name.starts(with: "@") {
                return "![\(match.raw)](\(traqServerURL.appending(path: "/public/icon/\(name.suffix(name.count - 1))")))"
            }

            guard let stamp = stamps.first(where: { $0.name == match.name }) else {
                return String(match.raw)
            }
            return "![\(match.raw)](\(traqServerURL.appending(path: "/stamps/\(stamp.id)/image")))"
        }
        // embeded links
        replaced.replace(
            /!(?<json>{"type":"(?<type>(channel|group|user))","raw":"(?<raw>[^"]*)","id":"(?<id>[0-9a-f-]+)"})/
        ) { match in
            "**[\(match.raw)](\(traqServerURL.appending(path: "/\(match.type)s/\(match.id)")))**"
        }

        return replaced
    }

    public var body: some View {
        MarkdownUI.Markdown(markdown)
            .markdownTheme(.basic)
            .markdownImageProvider(LazyImageProvider())
    }
}

package struct LazyImageProvider: @preconcurrency ImageProvider {
    // FIXME: Actor分離したい
    @MainActor package func makeImage(url: URL?) -> some View {
        let image = URLImage(url: url)
        if url?.relativePath.contains(/\/stamps\/[0-9a-f-]+\/image/) ?? false {
            image.frame(width: 16, height: 16)
        } else {
            image
        }
    }
}

#Preview {
    ScrollView {
        Markdown(
            #"""
            # h1 見出し
            ## h2 見出し
            ### h3 見出し
            #### h4 見出し
            ##### h5 見出し
            ###### h6 見出し
            
            *これはイタリック体の文字です*
            _これはイタリック体の文字です_
            
            **これは太文字です**
            __これは太文字です__
            
            ***これはイタリック体の太文字です***
            ___これはイタリック体の太文字です___
            
            ~~取り消し線~~
            ==マーカー==
            `インラインコード`
            
            [リンク](https://trap.jp)
            [wiki内リンク](/general)
            [タイトル付きリンク](https://trap.jp "タイトル")
            自動リンク https://trap.jp
            
            > 大なり記号「\>」をその直後か……
            >> ……スペースを挟んで追加することで……
            > > > ……引用部分をネストできます。
            
            ```
            Sample code/text here...
            ```
            
            ``` js:hello.js
            var foo = function (bar) {
              return bar++;
            };
            
            console.log(foo(5));
            ```
            
            + リストを作るには `+` か `-` もしくは`*` を行頭に入れます。
            + サブリストは2つのスペースで表されるインデントを追加します。
              - ハイフン(`-`)は強制的に新しいリストを作成します。
                * いろはにほへと
                + ちりぬるを
                - わかよたれそ
            + ね、簡単でしょう？
            
            1. つねならむ
            2. うゐのおくやま
            3. けふこえて
            
            1. 連続的な数字を使うことも出来ます……
            1. ……もしくは、全ての番号を `1.` にしても結果は変わりません
            1. feafw
            2. 332
            3. 242
            4. 2552
            1. e2
            
            57. foo
            1. bar
            
            | Option | Description |
            | ------ | ----------- |
            | data   | path to data files to supply the data that will be passed into templates. |
            | engine | engine to be used for processing templates. Handlebars is the default. |
            | ext    | extension to be used for dest files. |
            
            | left | center | right |
            | :-- | :-: | --: |
            | あ | い | う |
            
            ___
            
            - - -
            
            *******
            
            ![画像の説明](https://trap.jp/favicon.png)
            
            :buri1::buri2::buri3:
            
            :madai1;:madai2;
            
            $x_y = \frac{114}{514}$
            
            $$
            \begin{array}{c}
            \mathcal{F}[f(x)] = \frac{1}{\sqrt{2\pi}} \int_{-\infty}^{\infty} f(t) e^{-iut} dt \\ \\
            \mathcal{F}^{-1}[F(u)] = \frac{1}{\sqrt{2\pi}} \int_{-\infty}^{\infty} F(u) e^{iux} du
            \end{array}
            $$
            
            !!隠れる!!
            """#,
            stamps: [
                .init(
                    id: UUID().uuidString,
                    name: "buri1",
                    creatorId: UUID().uuidString,
                    createdAt: Date(),
                    updatedAt: Date(),
                    fileId: UUID().uuidString,
                    isUnicode: false,
                    hasThumbnail: false
                ),
            ]
        )
    }
}
