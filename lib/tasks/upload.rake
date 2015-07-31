namespace :upload do
  desc "Data dump"

  task :taste_awards => :environment do
    Wizard.delete_all
    Step.delete_all
    Option.delete_all

    account = Account.find_or_create_by!(phone_number: '254723555555', name: 'Eatout')
    wizard = Wizard.find_or_create_by!(account: account, start_keyword: 'TASTE',
      welcome_text: "Voting for Taste Awards is now open!\r\nTo Vote for your favourite establishments, reply to each question by selecting ONLY ONE nominee.\r\nYou must be over 18 to vote.")


    steps = {
      "Most Popular Italian" => [
        "360 Degrees Artisan Pizza",
        "La Dolce Vita",
        "La Salumeria",
        "Lucca, Villa Rosa Kempinski",
        "Mambo Italia",
        "Mediterraneo",
        "Mitende Atrium, Fairview",
        "Osteria",
        "Trattoria",
      ],
      "Most Polular Continental?" => [
        "About Thyme",
        "Artcaffe",
        "J’s Bar",
        "Monikos Kitchen",
        "QuePasa",
        "Secret Garden",
        "Seven Grill & Lounge, Village Market",
        "Sierra Brasserie",
        "Talisman",
        "Tamambo",
        "Eagles, Ole Sereni"
      ],
      "Most Popular East Africa/ Nyama Choma?" => [
        "Abyssinia",
        "Amaica",
        "Asmara",
        "Azalea Caribea",
        "Habesha",
        "Le Palanka",
        "Maxland",
        "Njugunas.",
        "Olepolos",
        "The Carnivore",
        "Smart Village"
      ],
      "Most Popular Indian" => [
        "Anghiti",
        "Bandhini, Intercontinental",
        "Chowpatty",
        "Haandi",
        "Hashmi",
        "Mughals",
        "Nargis",
        "Open House",
        "SaravanaBhavan",
        "Tiger Trail, Royal Orchid"
      ],
      "Most Popular Pan - Asian" => [
        "88 Kempinski",
        "Bamboo Zen Garden",
        "Bangkok",
        "Bar Asia Urban Eatery",
        "Double Dragon",
        "Emerald Garden",
        "Furusato",
        "Haru",
        "Misono",
        "Mister Wok",
        "Soi, Dusit D2",
        "Sushi Soo",
        "Thai Chi, Sarova Stanley",
        "Tokyo"
      ],
      "Most Popular Speciality Cuisine" => [
        "Adega",
        "Ambiance",
        "Cedars",
        "Fogo",
        "Le Palanka",
        "Masrawy Egyptian Restaurant",
        "Pampa",
        "Restaurant Table 49",
        "Fireplace, Urban Eatery "
      ],
      "Most Popular Food-on-the-go/ Franchise" => [
        "Big Square",
        "Chicken inn",
        "Debonairs",
        "Dominos",
        "Galitos",
        "KFC",
        "Naked Pizza",
        "Ocean Basket",
        "Pizza Inn",
        "Subway"
      ],
      "Most Popular Vegetarian" => [
        "Artcaffe",
        "Ashiana",
        "Chowpaty",
        "Emerald Garden",
        "Four Café Bistro",
        "Haandi ",
        "Phoenician",
        "Saravana Bhavan",
        "Slush"
      ],
      "Most Popular Café or Coffee House" => [
        "Artcaffe",
        "Colosseum",
        "Dormans",
        "Jade Coffee & Teahouse, Zen",
        "Java",
        "Leaf and Bean",
        "Mama’s",
        "Pete’s",
        "Vida"
      ],
      "Most Popular for Easy Dining in a Hotel" => [
        "Artisan, Sankara",
        "Baraka, Crowne Plaza",
        "Big Five, Ole Sereni",
        "Café Magreb, Serena",
        "Café Villa Rosa",
        "Flame Tree, Panafric",
        "Golden Spur Steak Ranch, Southern Sun",
        "Lord Delamere, Fairmont",
        "Mitende Atrium, Fairview",
        "Oro Restaurant & Lounge",
        "Pablos, Best Western",
        "Soko, Dusit D2",
        "Ventana, Bidwood Suites"
      ],      
      "Most Popular Bar in a Hotel" => [
        "Aksum, Nairobi Serena",
        "Cin Cin, Norfolk",
        "Cloud 9, Clarence House",
        "Level 8, Best Western",
        "Safari Bar, Intercontinental",
        "Sarabi, Sankara ",
        "The Nest, Tribe",
        "The Wine Cellar, Fairview ",
        "Zing, Dusit D2 ",
        "The Waterhole Bar, Ole Sereni"
      ],
      "Newcomer of the Year (* Must have opened in 2014 or 1st quarter of 2015)" => [                   
        "1824 Whiskey Bar",
        "Adega",
        "Caramel Restaurant & Lounge",
        "J's Fresh Bar & Kitchen",
        "Juniper Kitchen",
        "Mambo Italia",
        "Newscafe",
        "Ocean Basket",
        "Urban Eatery"
      ],
      "Most Popular Nightout Venue" => [                   
        "1824",
        "Bacchus",
        "Choices",
        "Ebony  ",
        "Florida",
        "Galileo",
        "Gypsy",
        "Havanna",
        "Klub House (K1)",
        "Rafiki’s",
        "Simba Saloon",
        "Skyluxx",
        "Vineyard"                  
      ],
      "Most Popular Restaurant at the Coast" => [                    
        "Ali Babours Cave (Diani)",
        "Sails (Diani)",
        "La Marinara (Mtwapa)",
        "Pavilions (Mombasa)",
        "Tamarind Dhow (Mombasa)",
        "Pili Pan (Watamu)",
        "Peponi Hotel Restaurant (Lamu)",
        "Moonrise (Lamu)",
        "The Moorings (Mtwapa)",
        "Rosada (Malindi)" ,
        "La Malindina (Malindi)",
      ],

      "Most Popular Bar at the Coast" => [                   
        "Yuls (Mombasa)",
        "Bobs Bar (Mombasa)",
        "Il Covo (Mombasa",
        "Pirates (Mombasa",
        "Tapas Cielo (Mombasa",
        "Forty Thieves (Diani",
        "Nomad Beach Bar (Diani",
        "360 Beach Bar, Diani Beach Reef Resort (Diani)",
        "Baharini Beach Bar, Swahili Beach (Diani)",
        "Pata Pata (Malindi)" 
      ]
    }

    steps.each_with_index do |step, idx|
      question = step.first

      st = Step.create! wizard: wizard, order_index: idx, step_type: 'menu', 
        wrong_answer: 'That is not a valid option please try again',
        rebound: 'Please type the name of your favourite restaurant in this category', name: question

      q = Question.create! step: st, text: question

      puts "Q: #{question}"
      options = step.last
      options.each_with_index do |opt, idx|
        puts "#{idx+1} : #{opt}"        
        Option.create! step: st, index: idx, key: idx+1, text: opt
      end

      st.reload
      num = st.options.count
      Option.create! step: st, index: num, key: num+1, text: "OTHER", option_type: 'other'
      
      puts "\r\n"
    end
  end
end