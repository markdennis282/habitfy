////
////  MenuSectionView.swift
////  habitfy Watch App
////
////  Created by Mark Dennis on 16/02/2025.
////
//import SwiftUI
//import Foundation
//struct MenuSectionView: View {
//    let store: HabitStore
//
//    var body: some View {
//        Group {
//            Section {
//                NavigationLink(destination: AddHabitView(store: store)) {
//                    MenuButtonContent(
//                        iconName: "plus.circle.fill",
//                        label: "Add Habit"
//                    )
//                }
//                .buttonStyle(.plain)
//            }
//            .listRowBackground(Color.blue.opacity(0.2))
//
//            Section {
//                NavigationLink(destination: LeaderboardView(store: store)) {
//                    MenuButtonContent(
//                        iconName: "person.3.sequence.fill",
//                        label: "Leaderboard"
//                    )
//                }
//                .buttonStyle(.plain)
//            }
//            .listRowBackground(Color.orange.opacity(0.2))
//
//            Section {
//                NavigationLink(destination: AnalyticsView(store: store)) {
//                    MenuButtonContent(
//                        iconName: "chart.bar.xaxis",
//                        label: "Analytics"
//                    )
//                }
//                .buttonStyle(.plain)
//            }
//            .listRowBackground(Color.purple.opacity(0.2))
//        }
//    }
//}
//
///// A small helper view for the icon + label layout.
//struct MenuButtonContent: View {
//    let iconName: String
//    let label: String
//
//    var body: some View {
//        VStack {
//            Image(systemName: iconName)
//                .font(.title2)
//            Text(label)
//                .font(.caption)
//        }
//        .frame(maxWidth: .infinity, minHeight: 44)
//        .contentShape(Rectangle())
//    }
//}
