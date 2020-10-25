extends Node

const SEMITONES = 5  # Stepsize in semitones between adjacent notes.

# A collection of all the notes that can be played and those in between.
const RUNES = {
    "A*": 1,
    "A-": 9,
    "A.": 17,
    "B*": 2,
    "B-": 10,
    "B.": 18,
    "C*": 6,
    "C-": 14,
    "C.": 22,
}

# Relative pitch scales.
const PITCH_SCALES = {
    0: 0.749,
    1: 1.0,
    2: 1.335,
}

# Number of pitches each cultist can sing.
const N_PITCHES = 3
