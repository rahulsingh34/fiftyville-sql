-- We know the theft took place on July 28th on Humphrey Street

-- Lets see if the crime scene reports has any more info
SELECT description 
FROM crime_scene_reports
WHERE day = 28 AND month = 7

-- This is what I found:
-- Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. 
-- Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.

-- Let's see what the witnesses said
SELECT transcript 
FROM interviews 
WHERE day = 28 AND month = 7 
AND transcript LIKE '%thief%' OR transcript LIKE '%theft%' OR transcript LIKE '%bakery%'

-- Here's what they said:
-- Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.
-- I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
-- As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.

-- Starting with the first witness, lets see if there's any insight
SELECT license_plate
FROM bakery_security_logs
WHERE day = 28 AND month = 7
AND hour = 10 AND minute >= 5 AND minute <= 15

-- We found 2 license plate numbers, R3G7486 & 13FNH73

-- Let's see who these plate numbers belong to
SELECT id, name, phone_number, passport_number
FROM people
WHERE license_plate = 'R3G7486' OR license_plate = '13FNH73'

-- Here's what I found: ID | Name | Phone Number | Passport Number
-- 325548 | Brandon | (771) 555-6667 | 7874488539
-- 745650 | Sophia | (027) 555-1068 | 3642612721

-- I want to see if either of these two were at the ATM (2nd witness report)
SELECT *
FROM atm_transactions
LEFT JOIN bank_accounts
ON atm_transactions.account_number = bank_accounts.account_number
INNER JOIN people
ON bank_accounts.person_id = people.id
WHERE atm_transactions.atm_location = 'Leggett Street' 
AND (bank_accounts.person_id = 325548 OR bank_accounts.person_id = 745650)

-- While Brandon had a withdrawl he was back after the incident, lets investigate Sophia first

-- Lets see if and who Sophia was on the phone with (3rd witness)
SELECT * 
FROM phone_calls
INNER JOIN people 
ON phone_calls.receiver = people.phone_number
WHERE phone_calls.caller = '(027) 555-1068'

-- Sophia called Robin for just over a minute, Robin also doesn't have a passport (interesting)
-- Robin (375) 555-8161 | 4V16VO0

-- I want to see if Sophia was on a flight leaving Fiftyville
SELECT people.name, airports.city, flights.hour,  flights.minute, flights.day
FROM people
INNER JOIN passengers
ON people.passport_number = passengers.passport_number
INNER JOIN flights 
ON passengers.flight_id = flights.id
INNER JOIN airports
ON flights.destination_airport_id = airports.id
WHERE people.passport_number = 3642612721
AND hour >= 10 AND minute > 15

-- Looks like Sophia left to Dallas shortly after the theft
-- Additionally, Sophia apparently left Fiftyville again 2 days later, this must be Robin

-- The thief is Sophia, shes in Dallas; her accomplice is Robin, she is in Los Angeles