.pragma library

// Takes in a "raw" phone number and cleans it so it only contains valid numbers.
// I.e. removes dashes, whitespaces. This idea is that that number should then be then ok
// to be passed forward to other components dealing with calls, SMSes and such.
function sanitizePhoneNumber(rawNumber)
{
    var whitelistedChars = "+pw#*"
    var cleanupRegExp = "[0-9" + whitelistedChars + "]"  // Dynamic regexp.
    var sanitizedPhoneNumber = "";

    for (var i=0; i<rawNumber.length; i++) {
        var currentCharTest = rawNumber.charAt(i);
        if (currentCharTest.toString().match(cleanupRegExp) !== null) {
            sanitizedPhoneNumber += currentCharTest.toString()
        }
    }

    return sanitizedPhoneNumber;
}

