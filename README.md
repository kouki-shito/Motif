# Motif - アイディアを失わせない、作曲家のためのボイスメモアプリ

## 概要

作曲者向けに特化したボイスメモアプリです。
作成したプロジェクトの中に曲に関するメモや音声、タグを保存でき、
良いアイディアをすぐ見つけられるようにすることを目的としています。

## 作った理由

普段作曲をする中で、既存のボイスメモアプリでは保存した音声を分類、整理する機能が乏しく、思いついたメロディーやアイディアが埋もれていってしまうという課題がありました。
これを解決するため、作曲に必要な情報や音声を整理し一元管理できるアプリを作成しました。

## 主な機能

- プロジェクトを作成して録音
- タイトルやジャンル、BPMといった情報のメモ機能
- 保存した音声を整理、視覚化するタグ機能

## 使用技術/開発体制

- Swift
- SwiftUI、TCA、sqlite-data
- CodeRabbitによるコードレビュー、Codexによる部分支援(汎用UIの生成など)
- LinearによるIssue管理
- アジャイル開発(練習の為)

## 技術的な工夫点

- パフォーマンス維持を意識

1. データベースにはSwiftDataではなくSQLiteを採用
2. TCAコードのパフォーマンス改善(Internal Actionの削減、Reducerの分割)
3. Instrumentsでパフォーマンス問題を監視

- コードベースの可読性を意識

1. Clean Architectureをベースにしたディレクトリ階層
2. Featureパターンの採用(Moduleベースへの移行を意識)
3. Reducer周りのActionをview,internal,delegateに分割し可読性を向上

## アーキテクチャ / 構成

- TCA pattern
- ディレクトリ構成(Feature + Mini Clean Architecture)

```
Motif
├── App
├── Core
│   ├── Components
│   ├── Networks
│   ├── Domains
│   ├── Resource
│   └── Utils
│       └── Extensions
└── Features
```

## 現状の課題

- 未実装の機能がある
- UI/UXの最適化が不十分

## ユーザーストーリーマップ

<img width="1660" height="602" alt="ユーザーストーリー マップ - フレーム 1" src="https://github.com/user-attachments/assets/7e63f4b6-cdcc-49fc-a737-e825453d2e0a" />
