# Letter Tracing App

An iPad/iPhone app built for early learners to practice tracing the first letters of CVC (consonant-vowel-consonant) words. Designed to supplement Kumon Level 5A reading exercises.

## Features

- **Letter tracing** — each word card displays the starting letter as a large, faint guide; children trace over it with their finger
- **CVC word sets** — 9 letter sets (b, c, d, f, h, p, r, s, t), each with 8 words shown across two pages of 4
- **Emoji word cards** — every word is paired with an emoji illustration to reinforce vocabulary
- **Celebration animation** — completing all 4 traces on a page triggers a "Great Job!" animation with animated spiders crawling across the screen and a procedurally generated celebration melody
- **Navigation** — Back and Forward buttons let learners move freely between pages and letter sets
- **Shuffled order** — letter sets are shuffled on each launch to vary the practice sequence

## Tech Stack

- Swift / UIKit
- AVFoundation (procedural audio synthesis — no audio files required)
- Programmatic layout (no storyboards)
- Minimum deployment target: iOS 15+

## Project Structure

```
LetterTracingApp/
├── AppDelegate.swift
├── Models/
│   └── WordData.swift          # WordItem, LetterSet, WordDataManager
├── ViewControllers/
│   └── MainViewController.swift  # Main screen, navigation, celebration logic
├── Views/
│   ├── LetterTracingView.swift   # Touch-drawable letter canvas
│   └── WordItemView.swift        # Word card (emoji + word + tracing view)
└── Audio/
    └── CelebrationSoundPlayer.swift  # AVAudioEngine-based melody synthesizer
```

## Getting Started

1. Clone the repo
2. Open `LetterTracingApp.xcodeproj` in Xcode
3. Select a simulator or connected device (iPad recommended for best layout)
4. Build and run (`⌘R`)

No third-party dependencies — no package manager setup required.

## How It Works

Each session shows one letter set at a time. The 8 words in a set are split into two pages of 4. Each word card shows:
- An emoji representing the word
- The word in lowercase
- A tracing box with the starting letter displayed faintly as a guide

The child traces the letter in each of the 4 boxes. Tapping **Forward →** registers a trace completion. Once all 4 are marked complete, the celebration sequence plays and the **Next Page** button appears to advance.
