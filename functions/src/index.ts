import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

admin.initializeApp();

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

        const batch = admin.firestore().batch();
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
