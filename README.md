# Crossword Together

## Table of Contents
1. [Overview](https://github.com/wildlifeniki/crossword_together/edit/main/README.md#overview)
1. [Product Spec](https://github.com/wildlifeniki/crossword_together/edit/main/README.md#product-spec)
1. [Wireframes](https://github.com/wildlifeniki/crossword_together/edit/main/README.md#wireframes)
1. [Schema](https://github.com/wildlifeniki/crossword_together/edit/main/README.md#schema)

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
* Can view profile stats and log out from profile page
* Leaderboard ranked by in-app stats
* Start new crossword game, option to check validity of board and has manual check to see when puzzle is complete
* Start new game and send invites to other users (username search function to add users)
* Tap on active game to enter game
* Allow player to request control of board and only active host can make changes on board
* Any player can tap on tiles to view clue for corresponding word
* Zoom in and out of board (not implementing)

**Optional Nice-to-have Stories**
* Have recently played with users showing when search bar is empty in invite screen
* Swipe to accept/deny invites
* Profile page for every user (Tap on recently played with or leaderboard)
* Settings to opt in/out of push notifications
* Additional competetive game option with slightly different mechanics
* Different difficulties of crosswords
* Different languages for crosswords
* Animation to added words or completed puzzle

### 2. Screen Archetypes

* Login (with facebook, if acccount has not been linked yet, creates app account automatically)
* Games Screen
  * Shows active games (Shows host name and profile picture, shows percent fill of board)
  * Shows pending invites (Shows who invite is from, can accept to move game to active games or deny to remove invite)
  * New game button takes to new game screen
* New Game Screen
  * Option to invite players
  * Search bar to add players
  * Later: Users recently played with automatically show before searching
* Self Profile Screen 
   * View profile picture, users recently played with, time/score statistics
* Game Board Screen
  * Visual of game board
  * Tap on tiles for clues
  * Indicator for which person is host/way to request host
* Leaderboard Screen/User Search Screen
  * Shows all users ranked by average time
  * Later: Search bar to view other profiles (essentially same search function)

Later:
* Settings Screen
   * App notification settings
* Other Profiles
  * View profile picture, statistics

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Games
* Leaderboard
* Profile
* Settings (fill later)

Later:
* Game options (Collaborative/Competetive)

**Flow Navigation** (Screen to Screen)
* Forced Log-in -> Games -> Game board (tap on active invite) OR New game (Instantiates game, returns to Games, auto-open game later)

Later:
* Leaderboard -> Other Profiles (tap on profile)
* Profile -> Other Profiles (tap on recent players profile)

## Wireframes!
![alt text](https://user-images.githubusercontent.com/22784306/180065208-8f7bcec5-2126-4245-bc16-12e8d6353919.png)

## Schema 
### Models
Note: all parse models come with unique objectId, updatedAt date, createdAt date

#### AppUser (Parse)
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | name | String | first and last name of user |
   | fbID | String | unique id that connects user to facebook api |
   | totalGames | Number | number of total games played|
   | bestTime | Number | best time of completion |
   | avgTime | Number | average time of completion |
   | recentlyPlayedWith | Array | list of ids of recent users played with |
   | activeGames | Array | list of game obectIds the user has accepted an invite for |
   | pendingInvites | Array | list of game object Ids the user has been invited to |

#### Game (Parse)
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | activePlayerIDs | Array | list of ids of players who have accepted invites (allowed to enter board) |
   | hostID | String | id of current host (starts as creator of game) |
   | inviteID | String | id of user who created the game (and therefore sent invites) |
   | time | Number | current time |
   | isCorrect | Boolean | indication if all words correct|
   | tilesArray | Array | 2d array of tile objectids that represent the board |
   | updated | Boolean | flag to show a change has been made, and non-host players will refresh |
   | requestedBy | String | id of user requesting host status |
   | requestingHost | Boolean | indication whether someone is requesting host status |

#### AppInfo (Parse)
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | fbID | String | id of user logged in |
   | invitedIDs | Array | array of ids of users invited to new game being created (cleared when canceled/invites sent)|

#### Pieces/tiles in board (Parse)
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | xIndex | Number | number indicating which column the tile is in |
   | yIndex | Number | number indicating which row the tile is in |
   | correctLetter | String | the expected letter for this tile |
   | inputLetter | String | the most recent input from the host for the letter |
   | acrossClue | String | clue linked with this tile associated with a word that goes across |
   | downClue | String | clue linked with this tile associated with a word that goes down |
   | fillable | Boolean | indicates whether this tile takes an input or not (if not, it is an empty tile and does not show up on the board |
   | gameID | String | the id of the game this tile is on the board for |
   
#### WordClue (Parse)
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | word | String | word connected to given clue |
   | clue | String | clue connected to given word |


### Technically Ambiguous Problems
#### Game Board Screen
   - Creating a custom view that depicts tiles in a grid pattern for a crossword. Making it so a user can enter a letter in a tile and view related clues depending on which tile a user is tapped into.
   - Allow changes from host to be updated and shown to all users present in the game
   - Display different clues based on selecting different words 
#### Crossword Algorithm
 - Implement a database of word/clue pairs
 - Write an alogrithm that can take words and assign them to tiles in basic crossword format
 - Be able to generate words that cross on certain tiles
