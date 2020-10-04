extends Node

const SEMITONES = 5  # Stepsize in semitones between adjacent notes.

# A collection of all the notes that can be played and those in between.
const NOTES = {
    "E4": 0,
    "F4": null,
    "F#4": null,
    "G4": 1,
    "G#4": null,
    "A4": 2,
    "A#4": null,
    "B4": 3,
    "C5": 4,
    "C#5": null,
    "D5": 5,
    "D#5": null,
    "E5": 8,
    "F5": 6,
    "F#5": null,
    "G5": 9,
    "G#5": null,
    "A5": 10,
    "A#5": null,
    "B5": 11,
    "C6": 12,
    "C#6": null,
    "D6": 13,
    "D#6": null,
    "E6": 16,
    "F6": 14,
    "F#6": null,
    "G6": null,
    "G#6": null,
    "A6": 18,
    "A#": null,
    "B6": null,
    "C7": null,
    "C#7": null,
    "D7": 21,
}

# Relative pitch scales.
const PITCH_SCALES = {
    0: 0.749,
    1: 1.0,
    2: 1.335,
}

# Number of pitches each cultist can sing.
const N_PITCHES = 3
