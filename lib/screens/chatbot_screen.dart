import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, String>> messages = [];
  String userInput = '';
  bool showOptions = true;
  List<String> currentOptions = [];
  bool waitingForCustomInput = false;
  bool showNextButton = false;
  bool showGoBackHome = false;
  bool awaitingEditSelection = false;
  String? awaitingNewValue;

  // Stores user selections
  Map<String, String> userSelections = {
    'cuisine': '',
    'restriction': '',
    'ingredients': '',
    'mealType': '',
    'cookingTime': '',
    'preference': '',
  };

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Start chat
  void startChat() {
    addBotMessage(
        "Hi there! Let's find the perfect recipes for you. I just need to know your preferences. Ready to start?");
    setState(() {
      currentOptions = ["Yes, let's go!", 'Not now'];
    });
  }

  // Handle user option selection
  void handleOptionSelection(String option) {
    addUserMessage(option);

    if (option == "Yes, let's go!") {
      askCuisine();
    } else if (option == 'Not now') {
      addBotMessage('No problem! You can start anytime. 😊');
      setState(() {
        showGoBackHome = true;
        currentOptions = [];
      });
    } else if (option == 'Start Over') {
      resetChat();
    } else if (option == 'Yes, Show Me Recipes!') {
      showRecipes();
    } else if (option == 'Type Here') {
      setState(() {
        waitingForCustomInput = true;
        showOptions = false;
      });
    } else if (option == 'Edit Preferences') {
      editPreferences();
      return;
    } else if (waitingForCustomInput) {
      setState(() {
        waitingForCustomInput = false;
        showOptions = true;
      });
      saveCustomInput(option);
    } else if (awaitingEditSelection) {
      handlePreferenceEdit(option);
    } else if (awaitingNewValue != null) {
      saveEditedPreference(option);
    } else {
      processSelection(option);
    }
  }

  // Save custom input to correct category
  void saveCustomInput(String option) {
    if (userSelections['cuisine']!.isEmpty) {
      setState(() {
        userSelections['cuisine'] = option;
      });
      askRestriction();
    } else if (userSelections['restriction']!.isEmpty) {
      setState(() {
        userSelections['restriction'] = option;
      });
      askIngredients();
    } else if (userSelections['ingredients']!.isEmpty) {
      setState(() {
        userSelections['ingredients'] = option;
      });
      askMealType();
    } else if (userSelections['mealType']!.isEmpty) {
      setState(() {
        userSelections['mealType'] = option;
      });
      askCookingTime();
    } else if (userSelections['cookingTime']!.isEmpty) {
      setState(() {
        userSelections['cookingTime'] = option;
      });
      askPreference();
    } else if (userSelections['preference']!.isEmpty) {
      setState(() {
        userSelections['preference'] = option;
      });
      showSummary();
    }
  }

  // Process predefined selections
  void processSelection(String option) {
    if (userSelections['cuisine']!.isEmpty) {
      setState(() {
        userSelections['cuisine'] = option;
      });
      askRestriction();
    } else if (userSelections['restriction']!.isEmpty) {
      setState(() {
        userSelections['restriction'] = option;
      });
      askIngredients();
    } else if (userSelections['ingredients']!.isEmpty) {
      setState(() {
        userSelections['ingredients'] = option;
      });
      askMealType();
    } else if (userSelections['mealType']!.isEmpty) {
      setState(() {
        userSelections['mealType'] = option;
      });
      askCookingTime();
    } else if (userSelections['cookingTime']!.isEmpty) {
      setState(() {
        userSelections['cookingTime'] = option;
      });
      askPreference();
    } else if (userSelections['preference']!.isEmpty) {
      setState(() {
        userSelections['preference'] = option;
      });
      showSummary();
    }
  }

  // Ask for Cuisine Type
  void askCuisine() {
    addBotMessage('What type of cuisine do you enjoy?🌍');
    setState(() {
      currentOptions = [
        'Indian 🍛',
        'Italian🍜',
        'Mexican🌮',
        'Chinese🥢',
        'Mediterranean🥗',
        'Type Here ..',
      ];
    });
  }

  // Ask for Dietary Restriction
  void askRestriction() {
    addBotMessage('Do you have any dietary preferences?');
    setState(() {
      currentOptions = [
        'Weight Gain',
        'High Protein',
        'Weight Loss',
        'Gluten-Free',
        'No Restrictions',
      ];
    });
  }

  // Ask for Ingredients to Exclude
  void askIngredients() {
    addBotMessage('Any ingredients you want to exclude?');
    setState(() {
      currentOptions = ['Mushrooms🍄', 'Gluten🍞', 'Type Here..'];
    });
  }

  // Ask for Meal Type
  void askMealType() {
    addBotMessage('What kind of meals are you looking for?');
    setState(() {
      currentOptions = [
        'Breakfast🍔',
        'Lunch 🥪',
        'Dinner🍽️',
        'Snacks🍿',
        'Desserts🍩',
      ];
    });
  }

  // Ask for Cooking Time
  void askCookingTime() {
    addBotMessage('How much time do you have to cook?');
    setState(() {
      currentOptions = ['0-15 mins🕛', '15-30 mins⏰', '30+ mins🕛'];
    });
  }

  // Ask for Cooking Preference
  void askPreference() {
    addBotMessage('Do you prefer simple or gourmet recipes?');
    setState(() {
      currentOptions = ['Simple and Quick🍴', 'Gourmet and Fancy🧑‍🍳'];
    });
  }

  // Show Summary before Recipes
  void showSummary() {
    addBotMessage('Here\'s what I learned about your preferences:');

    String summary = '''
     Cuisine: ${userSelections['cuisine']}
     
     Restriction: ${userSelections['restriction']}  
     Exclude: ${userSelections['ingredients']}  
     Meal Type: ${userSelections['mealType']}  
     Cooking Time: ${userSelections['cookingTime']}  
     Preference: ${userSelections['preference']}''';

    addBotMessage(summary);

    // Show Final Options
    setState(() {
      currentOptions = [
        'Yes, Show Me Recipes!',
        'Edit Preferences',
        'Start Over',
      ];
    });
  }

  // Handle "Show Me Recipes" option
  void showRecipes() {
    addBotMessage('Click Next to view recipes! 🍽');
    setState(() {
      showOptions = false;
      showNextButton = true;
    });
  }

  // Send a user message from input
  void sendMessage() {
    if (userInput.trim().isEmpty) return;
    addUserMessage(userInput);

    if (waitingForCustomInput) {
      saveCustomInput(userInput);
      setState(() {
        waitingForCustomInput = false;
        showOptions = true;
      });
    }

    setState(() {
      userInput = '';
      _textController.clear();
    });
  }

  // Add bot message
  void addBotMessage(String text) {
    setState(() {
      messages.add({
        'sender': 'bot',
        'text': text,
        'time': getCurrentTime(),
      });
    });
    _scrollToBottom();
  }

  // Add user message
  void addUserMessage(String text) {
    setState(() {
      messages.add({
        'sender': 'user',
        'text': text,
        'time': getCurrentTime(),
      });
    });
    _scrollToBottom();
  }

  void resetChat() {
    setState(() {
      messages = [];
      userSelections = {
        'cuisine': '',
        'restriction': '',
        'ingredients': '',
        'mealType': '',
        'cookingTime': '',
        'preference': '',
      };
      showOptions = true;
    });
    startChat();
  }

  // Get current time in HH:MM AM/PM format
  String getCurrentTime() {
    return DateFormat('h:mm a').format(DateTime.now());
  }

  void editPreferences() {
    addBotMessage('Which preference would you like to edit?');
    setState(() {
      currentOptions = [
        'Cuisine',
        'Dietary Restrictions',
        'Ingredients',
        'Meal Type',
        'Cooking Time',
        'Preference',
        'Cancel',
      ];
      awaitingEditSelection = true;
    });
  }

  void handlePreferenceEdit(String option) {
    if (option == 'Cancel') {
      addBotMessage('Edit canceled. Let me know if you need changes later.');
      setState(() {
        awaitingEditSelection = false;
      });
      return;
    }

    setState(() {
      awaitingEditSelection = false;
      awaitingNewValue = option;
    });
    addBotMessage('Please enter a new value for $option:');

    // Set options based on user selection
    if (option == 'Cuisine') {
      setState(() {
        currentOptions = [
          'Indian 🍛',
          'Italian 🍜',
          'Mexican 🌮',
          'Chinese 🥢',
          'Type Here',
        ];
      });
    } else if (option == 'Dietary Restrictions') {
      setState(() {
        currentOptions = [
          'Weight Gain',
          'High Protein',
          'Weight Loss',
          'Gluten-Free',
          'No Restrictions',
        ];
      });
    } else if (option == 'Ingredients') {
      setState(() {
        currentOptions = ['Mushrooms 🍄', 'Gluten 🍞', 'Type Here'];
      });
    } else if (option == 'Meal Type') {
      setState(() {
        currentOptions = [
          'Breakfast 🍳',
          'Lunch 🥪',
          'Dinner 🍽️',
          'Snacks 🍿',
          'Desserts 🍩',
        ];
      });
    } else if (option == 'Cooking Time') {
      setState(() {
        currentOptions = ['0-15 mins 🕛', '15-30 mins ⏰', '30+ mins 🕛'];
      });
    } else if (option == 'Preference') {
      setState(() {
        currentOptions = ['Simple and Quick 🍴', 'Gourmet and Fancy 🧑‍🍳'];
      });
    }
  }

  void saveEditedPreference(String newValue) {
    if (awaitingNewValue == null) {
      return;
    }

    // Map option name to userSelections keys
    const preferenceMap = {
      'Cuisine': 'cuisine',
      'Dietary Restrictions': 'restriction',
      'Ingredients': 'ingredients',
      'Meal Type': 'mealType',
      'Cooking Time': 'cookingTime',
      'Preference': 'preference',
    };

    final preferenceKey = preferenceMap[awaitingNewValue];

    if (preferenceKey != null) {
      setState(() {
        userSelections[preferenceKey] = newValue;
      });
      addBotMessage('$awaitingNewValue updated to: $newValue');
    }

    setState(() {
      awaitingNewValue = null;
    });

    showUpdatedSummary();
  }

  void showUpdatedSummary() {
    addBotMessage('Your updated preferences: ${userSelections.toString()}');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/chatbot.png'),
              radius: 15,
            ),
            const SizedBox(width: 10),
            const Text('Recipe Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Column(
                  children: [
                    Align(
                      alignment: message['sender'] == 'bot'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: message['sender'] == 'bot'
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              if (message['sender'] == 'bot')
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/chatbot.png'),
                                      radius: 15,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(12.0),
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: Text(
                                          message['text']!,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (message['sender'] == 'user')
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    message['text']!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  message['time']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Show options right after the bot message
                    if (index == messages.length - 1 && 
                        message['sender'] == 'bot' && 
                        showOptions && 
                        currentOptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: currentOptions
                              .map((option) => ChoiceChip(
                                    label: Text(option),
                                    selected: false,
                                    onSelected: (_) => handleOptionSelection(option),
                                    backgroundColor: Colors.grey[200],
                                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                    labelStyle: const TextStyle(fontSize: 14),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (showGoBackHome)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('GO BACK TO HOME →'),
              ),
            ),
          if (!showOptions || waitingForCustomInput)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (value) => userInput = value,
                      decoration: InputDecoration(
                        hintText: 'Type here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                      onSubmitted: (value) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          if (showNextButton)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: showRecipes,
                child: const Text('Next'),
              ),
            ),
        ],
      ),
    );
  }
}