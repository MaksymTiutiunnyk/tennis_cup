import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// create matches for tournament
exports.createMatchesOnTournamentCreation = functions.firestore
    .document('tournaments/{tournamentId}')
    .onCreate(async (snapshot, context) => {
        const tournamentData = snapshot.data();
        if (!tournamentData || !tournamentData.players || !tournamentData.date) return;

        const players = tournamentData.players;
        const tournamentId = context.params.tournamentId;

        const startDateTime = tournamentData.date.toDate();
        const intervalMillis = 30 * 60 * 1000;

        const matches = [];
        let currentStartTime = startDateTime;

        for (let i = 0; i < players.length; i++) {
            for (let j = i + 1; j < players.length; j++) {
                const match = {
                    bluePlayerId: players[i],
                    redPlayerId: players[j],
                    blueScore: 0,
                    redScore: 0,
                    blueSetScores: [0, 0, 0, 0, 0],
                    redSetScores: [0, 0, 0, 0, 0],
                    dateTime: admin.firestore.Timestamp.fromDate(new Date(currentStartTime)),
                    tournamentId: tournamentId,
                };
                matches.push(match);

                currentStartTime = new Date(currentStartTime.getTime() + intervalMillis);
            }
        }

        const batch = db.batch();
        const matchesCollectionRef = admin.firestore()
            .collection('tournaments')
            .doc(tournamentId)
            .collection('matches');

        matches.forEach(match => {
            const matchDocRef = matchesCollectionRef.doc();
            batch.set(matchDocRef, match);
        });

        await batch.commit();
        console.log('Matches created successfully for tournament:', tournamentId);
    });


// update amount of tournaments for a player
exports.updateTournamentCount = functions.firestore
    .document("tournaments/{tournamentId}")
    .onCreate(async (snapshot, context) => {
        const tournamentData = snapshot.data();
        const players = tournamentData.players;

        const batch = db.batch();
        players.forEach((playerId: string) => {
            const playerRef = db.collection("players").doc(playerId);
            batch.update(playerRef, {
                tournaments: admin.firestore.FieldValue.increment(1),
            });
        });

        await batch.commit();
    });


// update amount of matches for a player
exports.updateMatchCount = functions.firestore
    .document("tournaments/{tournamentId}/matches/{matchId}")
    .onCreate(async (snapshot, context) => {
        const matchData = snapshot.data();
        const { bluePlayerId, redPlayerId } = matchData;

        const batch = db.batch();

        [bluePlayerId, redPlayerId].forEach((playerId) => {
            const playerRef = db.collection("players").doc(playerId);
            batch.update(playerRef, {
                matches: admin.firestore.FieldValue.increment(1),
            });
        });

        await batch.commit();
    });


// update setScores
exports.updateSetScores = functions.firestore
    .document("tournaments/{tournamentId}/matches/{matchId}")
    .onUpdate(async (change, context) => {
        const after = change.after.data();
        const before = change.before.data();

        if (!after || !after.blueSetScores || !after.redSetScores) {
            console.error("Invalid document structure");
            return;
        }

        let blueSetsWon: number = 0;
        let redSetsWon: number = 0;

        for (let i = 0; i < after.blueSetScores.length; i++) {
            if (
                after.blueSetScores[i] > 10 &&
                after.blueSetScores[i] - after.redSetScores[i] > 1
            ) {
                blueSetsWon++;
            } else if (
                after.redSetScores[i] > 10 &&
                after.redSetScores[i] - after.blueSetScores[i] > 1
            ) {
                redSetsWon++;
            }
        }

        const updates: { [key: string]: any } = {};

        if (blueSetsWon != before.blueScore) {
            updates.blueScore = blueSetsWon;
        }
        if (redSetsWon != before.redScore) {
            updates.redScore = redSetsWon;
        }

        if (Object.keys(updates).length > 0) {
            await change.after.ref.update(updates);
        }
    });


// update player's wins and loses
exports.updateWinsAndLosses = functions.firestore
    .document("tournaments/{tournamentId}/matches/{matchId}")
    .onUpdate(async (change, context) => {
        const after = change.after.data();

        if (after.blueScore != 3 && after.redScore != 3) {
            return;
        }

        const winner = after.blueScore == 3 ? after.bluePlayerId : after.redPlayerId;
        const loser = after.blueScore == 3 ? after.redPlayerId : after.bluePlayerId;

        const winnerRef = db.collection("players").doc(winner);
        const loserRef = db.collection("players").doc(loser);

        const batch = db.batch();

        batch.update(winnerRef, {
            wins: admin.firestore.FieldValue.increment(1),
        });

        batch.update(loserRef, {
            loses: admin.firestore.FieldValue.increment(1),
        });

        await batch.commit();
    }
    );


// update points of each player of the tournament
exports.updatePoints = functions.firestore
    .document("tournaments/{tournamentId}/matches/{matchId}")
    .onUpdate(async (change, context) => {
        const after = change.after.data();

        if (after.blueScore != 3 && after.redScore != 3) {
            return;
        }

        const winner = after.blueScore == 3 ? after.bluePlayerId : after.redPlayerId;
        const loser = after.blueScore == 3 ? after.redPlayerId : after.bluePlayerId;

        const tournamentRef = change.after.ref.parent.parent;
        if (!tournamentRef) {
            console.error("Parent tournament document not found");
            return;
        }

        const tournamentSnapshot = await tournamentRef.get();
        const tournamentData = tournamentSnapshot.data();

        if (!tournamentData || !tournamentData.players || !tournamentData.points) {
            console.error("Invalid tournament structure");
            return;
        }

        const players: string[] = tournamentData.players;
        const points: number[] = tournamentData.points;

        const winnerIndex = players.indexOf(winner);
        const loserIndex = players.indexOf(loser);

        if (winnerIndex == -1 || loserIndex == -1) {
            console.error("Winner or loser not found in the players list");
            return;
        }

        points[winnerIndex] += 2;
        points[loserIndex] += 1;

        try {
            await tournamentRef.update({ points });
        } catch (error) {
            console.error("Error updating points:", error);
        }
    });



// update places when all matches are over
exports.updatePlaces = functions.firestore
    .document("tournaments/{tournamentId}")
    .onUpdate(async (change, context) => {
        const after = change.after.data();

        let totalPoints = 0;
        for (let i = 0; i < after.points.length; i++) {
            totalPoints += after.points[i];
        }

        if (totalPoints != 45) return;

        const players = after.points.map((points: any, index: any) => ({
            index,
            points,
        }));

        players.sort((a: any, b: any) => b.points - a.points);

        const places = Array(after.points.length).fill(0);
        let currentPlace = 1;

        for (let i = 0; i < players.length; i++) {
            if (i > 0 && players[i].points < players[i - 1].points) {
                currentPlace = i + 1;
            }
            places[players[i].index] = currentPlace;
        }

        await change.after.ref.update({
            places,
            isFinished: true,
        });
    });


// update players' medals after tournament
exports.updateMedals = functions.firestore
    .document("tournaments/{tournamentId}")
    .onUpdate(async (change, context) => {
        const after = change.after.data();

        if (!after.isFinished) return;

        if (!after.places || !after.players) {
            console.error("Missing 'places' or 'players' field in tournament document.");
            return;
        }

        if (after.places.length != after.players.length) {
            console.error("'places' and 'players' arrays must have the same length.");
            return;
        }

        const batch = admin.firestore().batch();
        const playersCollection = admin.firestore().collection("players");

        after.places.forEach((place: any, index: any) => {
            const playerId = after.players[index];
            const playerRef = playersCollection.doc(playerId);

            const updates: { [key: string]: any } = {};
            if (place == 1) updates.gold = admin.firestore.FieldValue.increment(1);
            if (place == 2) updates.silver = admin.firestore.FieldValue.increment(1);
            if (place == 3) updates.bronze = admin.firestore.FieldValue.increment(1);

            if (Object.keys(updates).length > 0) {
                batch.update(playerRef, updates);
            }
        });

        try {
            await batch.commit();
            console.log("Medal counts updated successfully.");
        } catch (error) {
            console.error("Error updating medals: ", error);
        }
    });


