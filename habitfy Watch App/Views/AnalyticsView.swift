
import SwiftUI


struct AnalyticsView: View {
    @ObservedObject var store: HabitStore
    
    var body: some View {
        TabView {
            DailyRangeAnalyticsView(store: store, dayRange: 7)
            DailyRangeAnalyticsView(store: store, dayRange: 30)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))//allow swipe between habits
    }
}







