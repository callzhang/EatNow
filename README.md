# Eat-Now 1.0 Specification
## Eat-Now iPhone App
### The Basics
- Optimized for iPhone 5, iPhone 6 and iPhone 6 Plus.
- Requires Location Permission. 
- No Push Notification Permission.
- Eat-Now major feature is **Instant Restaurant Search**, from app launch to restaurants search *Cards* available requires less than **5** seconds.
- Eat-Now’s philosophy is simple, elegant and instantly helpful.

### Card Deck View
- Eat-Now offers **12** *Cards* and a *Refresh* button as the 13th *Card* at a time on the *Card Deck View*.
- *Card Deck View* also offers a button to reveal *History View*.
- User may choose to refresh the *Card Deck View* and get another **12** *Cards* at the end of the deck.
- For each *Card*, user can either *Next*, or *View Details*.
- Once user chooses to *View Details* of a card, the card transform into a *Card Details View*.
- Once user chooses *Next*, the *Card* gets discarded after a *Toss Animation*.
- Once user taps on the *History* button, the *History View* that contains the history of user behaviors will be revealed, after a *Push animation*.
- While remain active and on the foreground, the *Card Deck View* refreshes itself once location change is detected. 
- **Other scenarios that will cause the Card Deck View to refresh itself.(TBD)**

### Card Details View
- On *Card Details View*, user can either *Dismiss* the *Card Details View*, *Next*, or choose *I’m Going*!.
- Once user dismisses the *Card Details View*, the *Card Details View* gets dismissed and the *Card Deck View* comes back, with the same *Card* on top of it, after a *Transform Animation*.
- Once user chooses *Next* on a *Card Details View*, the *Card Details View* gets dismissed and the *Card Deck View* comes back, with the next *Card* on top of it, after a *Toss Animation*.
- Once user chooses *I’m Going*!, a pop-up view will show up. 

#### I’m Going Pop-up View
- ensures user with a conforming message like “Great Choice! Bon Appetite!” and two options, *Get Me There* and *Done*.
- Choosing *Get Me There*, will reveal a Navigation View, showing user directions to the according restaurant.
- Choosing *Done* will dismiss the pop-up view and direct user back to the *Card Details View*. 

#### Navigation View
- **Walking is the default Transport Mode, while “Driving” is the other option.(TBD)**
- **On the Navigation View, user can also choose to Show Directions in Apple Maps or Show Directions in Google Maps. (TBD)**

### Card Details View (continued)
- Once user comes back to the “Card Details View“ by choosing *Done* on the pop-up view, or dismissing the *Navigation View*, the *I’m Going*! turns inactive and cannot be tapped again. This state will be removed once this *Card* is dismissed by user tapping on *Next*, either on the *Card Deck View* or *Card Details View*.
- Additionally, on the *Card Details View* of the restaurants user has been to and left feedback for, a *Feedback Icon*, *Good*, *It’s OK*, or *Not Good*, will be displayed. User may tap on the *Feedback Icon* to alter the feedback.

### History View
- *History View* is a view that shows a list of history restaurants user has chosen *I’m Going*!.
- Each history item looks like a mini card, in order to be consistent to the *Card Deck View*.
- Each history item shows the basic info of the restaurant, together with the user feedback icon, *Good*, *It’ OK*, or *Not Good*.
- History items are grouped by date the user chose “I’m Going!“, most recent first.
- Tapping on any history item will reveal the *Card Details View* of corresponding restaurant, after a “Transform Animation“.

### Feedback Card
- *Feedback Card* shows upon app launch the next day each time user chooses “I’m Going!” on a *Card Details View*. 
- *Feedback Card* displays basic information of the restaurant, and offers four options, *Good*, *It’s OK*, *Not Good*, and *Didn’t Go*. The first three have their own graphic icons, while  the option *Didn’t Go* plays humble.
- *Feedback Card* cannot be dismissed until one of the four options has been chosen.
- Once user chooses any options on the *Feedback Card*, the *Card* gets dismissed with a *Toss Animation*. The next immediate *Card* is a normal restaurant *Card*.
- If user choose “Didn’t Go”, the restaurant will be removed from user history in database and from History View as well.
- “Feedback Card” is part of the “Card Deck View” and should remain consistent with the view.

## Eat-Now Apple Watch App
### The Basics
- Eat-Now Apple Watch App only offers limited functionality, including only restaurant searching, restaurant details and submitting feedback.
- Eat-Now Apple Watch App does not require Notification permission.

### Paginated Card Deck View
- Twelve restaurant *Cards* becomes available upon app launch, with the 13th *Card* as a *Refresh* button.
- Each restaurant Card shows brief information of the restaurant.
- Tapping on any restaurant *Card* will reveal the corresponding *Card Details View*.
- User may swipe left and right to navigate through the *Cards*.
- *Cards* cannot be dismissed or tossed away like Eat-Now iPhone app. The twelve *Cards* will always remain available, until user choose to *Refresh* the *Cards*.
- Tapping on the 13th *Card*, aka the *Refresh* button will refresh the twelve restaurant *Cards* with another set of 12 twelve restaurant *Cards*.
- *Digital Crown* can be used to navigate through *Cards*.
 
### Card Details View
- *Card Details View* shows more information of the restaurant, and offers only one option, as *I’m Going*!. User can also navigate back to the *Paginated Card Deck* View by using the system *Back* button.
- *Card Details View* also shows user feedback icon, *Good*, *It’s OK* or *Not Good*, if user has been to this restaurant previously(choosing *I’m Going*! on *Card Details View*) and left feedback.
- Choosing *I’m Going*! does not trigger another view or pop-up like Eat-Now iPhone app, instead, it makes the *I’m Going*! button inactive and replace the button text label with Bon Appetite!.
- A note at the end of the view saying, “You may use Eat-Now iPhone App to get directions to the venue.”

### Continuity/Handoff
- *Cards* displayed on iPhone and Apple Watch should be identical at the same time.
- **Further functionalities TBD**.

### Glance
- *Glance* shows a summary view of the top three restaurants from the *Paginated Card Deck View*, by showing the restaurant name, rating, and distance.
- Tapping on the *Glance* view will launch the Eat-Now Apple Watch App, showing the top restaurants in the *Paginated Card Deck View*.

## Pending Questions
- Choose Navigation on Apple Maps and then Navigate using Apple Watch.
- What data is available for each restaurant from Foursquare? Assuming we will switch to Foursquare soon.
