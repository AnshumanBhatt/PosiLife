//
//  QuoteDataManager.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import Foundation

class QuoteDataManager: ObservableObject {
    @Published var allQuotes: [Quote] = []
    @Published var currentQuote: Quote?
    
    init() {
        loadQuotes()
        setRandomCurrentQuote()
    }
    
    private func loadQuotes() {
        allQuotes = [
            // Study Quotes
            Quote(text: "Education is the most powerful weapon which you can use to change the world.", author: "Nelson Mandela", category: .study),
            Quote(text: "The beautiful thing about learning is that no one can take it away from you.", author: "B.B. King", category: .study),
            Quote(text: "Study hard what interests you the most in the most undisciplined, irreverent and original manner possible.", author: "Richard Feynman", category: .study),
            Quote(text: "Learning never exhausts the mind.", author: "Leonardo da Vinci", category: .study),
            Quote(text: "The expert in anything was once a beginner.", author: "Helen Hayes", category: .study),
            
            // Job/Career Quotes
            Quote(text: "Choose a job you love, and you will never have to work a day in your life.", author: "Confucius", category: .job),
            Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill", category: .job),
            Quote(text: "Opportunities don't happen. You create them.", author: "Chris Grosser", category: .job),
            Quote(text: "Don't be afraid to give up the good to go for the great.", author: "John D. Rockefeller", category: .job),
            Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney", category: .job),
            
            // Health Quotes
            Quote(text: "To keep the body in good health is a duty... otherwise we shall not be able to keep our mind strong and clear.", author: "Buddha", category: .health),
            Quote(text: "Health is a state of complete harmony of the body, mind and spirit.", author: "B.K.S. Iyengar", category: .health),
            Quote(text: "Take care of your body. It's the only place you have to live.", author: "Jim Rohn", category: .health),
            Quote(text: "A healthy outside starts from the inside.", author: "Robert Urich", category: .health),
            Quote(text: "The first wealth is health.", author: "Ralph Waldo Emerson", category: .health),
            
            // Motivation Quotes
            Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: .motivation),
            Quote(text: "Life is what happens to you while you're busy making other plans.", author: "John Lennon", category: .motivation),
            Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", category: .motivation),
            Quote(text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle", category: .motivation),
            Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", category: .motivation),
            
            // Mindfulness Quotes
            Quote(text: "The present moment is the only time over which we have dominion.", author: "Thích Nhất Hạnh", category: .mindfulness),
            Quote(text: "Mindfulness is a way of befriending ourselves and our experience.", author: "Jon Kabat-Zinn", category: .mindfulness),
            Quote(text: "Yesterday is history, tomorrow is a mystery, today is a gift.", author: "Eleanor Roosevelt", category: .mindfulness),
            Quote(text: "Peace comes from within. Do not seek it without.", author: "Buddha", category: .mindfulness),
            Quote(text: "The mind is everything. What you think you become.", author: "Buddha", category: .mindfulness),
            
            // Success Quotes
            Quote(text: "Success is not the key to happiness. Happiness is the key to success.", author: "Albert Schweitzer", category: .success),
            Quote(text: "Don't be afraid to fail. Be afraid not to try.", author: "Michael Jordan", category: .success),
            Quote(text: "Success is walking from failure to failure with no loss of enthusiasm.", author: "Winston Churchill", category: .success),
            Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins", category: .success),
            Quote(text: "Success is not in what you have, but who you are.", author: "Bo Bennett", category: .success),
            
            // Relationships Quotes
            Quote(text: "The greatest gift of life is friendship, and I have received it.", author: "Hubert H. Humphrey", category: .relationships),
            Quote(text: "Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.", author: "Lao Tzu", category: .relationships),
            Quote(text: "The best way to find out if you can trust somebody is to trust them.", author: "Ernest Hemingway", category: .relationships),
            Quote(text: "A friend is someone who knows all about you and still loves you.", author: "Elbert Hubbard", category: .relationships),
            Quote(text: "In the end, we will remember not the words of our enemies, but the silence of our friends.", author: "Martin Luther King Jr.", category: .relationships),
            
            // Creativity Quotes
            Quote(text: "Creativity is intelligence having fun.", author: "Albert Einstein", category: .creativity),
            Quote(text: "The creative adult is the child who survived.", author: "Ursula K. Le Guin", category: .creativity),
            Quote(text: "You can't use up creativity. The more you use, the more you have.", author: "Maya Angelou", category: .creativity),
            Quote(text: "Imagination is more important than knowledge.", author: "Albert Einstein", category: .creativity),
            Quote(text: "Every artist was first an amateur.", author: "Ralph Waldo Emerson", category: .creativity),
            
            // Fitness Quotes
            Quote(text: "The body achieves what the mind believes.", author: "Napoleon Hill", category: .fitness),
            Quote(text: "Fitness is not about being better than someone else. It's about being better than you used to be.", author: "Khloe Kardashian", category: .fitness),
            Quote(text: "Your body can do it. It's your mind that you have to convince.", author: "Unknown", category: .fitness),
            Quote(text: "A one-hour workout is 4% of your day. No excuses.", author: "Unknown", category: .fitness),
            Quote(text: "The groundwork for all happiness is good health.", author: "Leigh Hunt", category: .fitness),
            
            // General Quotes
            Quote(text: "Be yourself; everyone else is already taken.", author: "Oscar Wilde", category: .general),
            Quote(text: "In the end, we only regret the chances we didn't take.", author: "Lewis Carroll", category: .general),
            Quote(text: "Life is really simple, but we insist on making it complicated.", author: "Confucius", category: .general),
            Quote(text: "The only way to make sense out of change is to plunge into it, move with it, and join the dance.", author: "Alan Watts", category: .general),
            Quote(text: "Happiness is not something ready made. It comes from your own actions.", author: "Dalai Lama", category: .general)
        ]
    }
    
    func getQuotesForAgenda(_ agenda: Agenda) -> [Quote] {
        return allQuotes.filter { $0.category == agenda }
    }
    
    func getRandomQuote(for agenda: Agenda) -> Quote? {
        let filteredQuotes = getQuotesForAgenda(agenda)
        return filteredQuotes.randomElement()
    }
    
    func getRandomQuote() -> Quote? {
        return allQuotes.randomElement()
    }
    
    func setRandomCurrentQuote(for agenda: Agenda? = nil) {
        if let agenda = agenda {
            currentQuote = getRandomQuote(for: agenda)
        } else {
            currentQuote = getRandomQuote()
        }
    }
    
    func getQuotesForToday(agenda: Agenda, count: Int) -> [Quote] {
        let quotesForAgenda = getQuotesForAgenda(agenda)
        return Array(quotesForAgenda.shuffled().prefix(count))
    }
}
