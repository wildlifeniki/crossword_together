# EXAMPLE GROUP PROJECT README

# Crosswords

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
1. [Schema](#Schema)

## Overview
### Description
Crossword app that allows people to collaborate on puzzles by inviting people to boards and letting the host fill in clues. The app also tracks stats and has a leaderboard of all the users.

### App Evaluation
- **Category:** Social/Gaming
- **Mobile:** This app would probably start out as being developed for mobile, but I can definitely see an equivalent use on a computer. Collaborative gaming isn't limited to mobile, but I think the main draw is that mobile is easier to access for more people.
- **Story:** Generates crosswords, allows users to start new boards and invite other users to play on that board together. Can login with facebook or create profile. Tracks individual user stats and ranks all users on a leaderboard.
- **Market:** Anyone can use this app, the target audience is anyone looking to do crosswords with other people. 
- **Habit:** This app could definitely be habit forming, as it is a mobile game with a social aspect. Looking at other crossword apps or social games shows how these apps promote user interaction.
- **Scope:** At the start this app is a simple way for users to collaborate on single puzzles and keep track of stats on their profiles. This could be expanded with other game modes (competitive) or improved crossword generation with different difficulties or user-input clues.

## Product Spec
### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User logs in to view profile or start new game
* Profile page for every user
* Leaderboard ranked by in-app stats
* Start new crossword game, option to check validity of board and autochecks when puzzle is complete
* Invite users to play in active game (username search function to add users, recently played with at top)
* Allow player to request control of board and only active host can make changes on board
* Any player can tap on tiles to view clue for corresponding word
* Zoom in and out of board
* Settings to opt in/out of push notifications

**Optional Nice-to-have Stories**

* Additional competetive game option with slightly different mechanics
* Different difficulties of crosswords
* Different languages for crosswords
* Animation to added words or completed puzzle

### 2. Screen Archetypes

* Login (option to log in with facebook)
* Register - User signs up or logs into their account
* Games Screen
  * Shows active invites (can accept to jump into game or deny to remove invite)
  * New game button takes to new game screen
* New Game Screen
  * Option to invite players
  * Users recently played with automatically show before searching
  * Search bar to add players
* Self Profile Screen 
   * View profile picture, users recently played with, time/score statistics, rank
   * Edit Settings
* Other Profiles
  * View profile picture, rank, statistics
* Game Board Screen
  * Visual of game board
  * Tap on tiles for clues
  * Indicator for which person is host/way to request host
  * Ability to invite players
* Leaderboard Screen/User Search Screen
  * Shows all users ranked by time/score
  * Search bar to view other profiles (essentially same search function)
* Settings Screen
   * App notification settings

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* New Game
* Profile
* Settings

Optional:
* Game options (Collaborative/Competetive)

**Flow Navigation** (Screen to Screen)
* Forced Log-in -> Sign up/account creation if log in is unavailable
* Leaderboard -> Other Profiles (tap on profile)
* Profile -> Settings (tap on settings) OR Other Profiles (tap on recent players profile)
* Games -> Game board (tap on active invite) OR New game -> Game board (start new game from screen)

## Wireframes
<img src="https://i.imgur.com/a/d4ey914.jpg" width=800><br>

## Schema 
### Models

#### Player
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Id | String | unique id for the player |
   | User | pointer to user | user when they are in a game |
   | isHost | Boolean | indication whether player has control over board |
   | color | String | color of word once shared to entire game |
   | isRequestingHost | Boolean | indication if player is trying to get control over board |


#### User 
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Username | String | unique id for the user |
   | profile_pic | Image | profile picture for user|
   | total_games | Number | number of total games played|
   | best_time | Number | best time of completion |
   | avg_time | Number | average time of completion |
   | recent_players | Array | List of recent user objects played with|

#### Gameboard 
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Id | String | unique id for the game board |
   | Players | Array | list of player objects in gameboard |
   | Words | Array | list of words on gameboard |
   | Time | Number | current time |
   | isCorrect | Boolean | indication if all words correct|

#### Pieces/tiles in board
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Id | String | unique id for the player |
   | input | String | letter input by host |
   | goal_letter | String | correct letter for tile |
   | isCorrect | Boolean | input is correct |


#### Word in board 
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Id | String | unique id for the word |
   | Clue | String | hint for word |
   | Tiles | Array | list of tile objects (letters that make up word)|
   | isCorrect | Boolean | indication if all tiles correct |

#### Leaderboard 
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | Users | Array | list of user objects |

### Networking
#### List of network requests by screen
   - Game Board Screen
      - (Update) Host finishes entering a word
   - New Game Screen
      - (Send) Send invite to other users
   - Games Screen
      - (Join) Join game board llobby
   - Profile Screen
      - (Update/PUT) Update user profile image

