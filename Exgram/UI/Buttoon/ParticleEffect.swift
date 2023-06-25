//
//  ParticleEffect.swift
//  Exgram
//
//  Created by Artem Listopadov on 25.06.23.
//

import SwiftUI

// Custom View Modifier
extension View {
    @ViewBuilder
    func particleEffect(systemImage: String, status: Bool, activeTint: Color, inActiveTint: Color) -> some View {
        self
            .modifier(
                ParticleModifier(systemImage: systemImage, status: status, activeTint: activeTint, inActiveTint: inActiveTint)
            )
    }
}

fileprivate struct ParticleModifier: ViewModifier {
    var systemImage: String
    var status: Bool
    var activeTint: Color
    var inActiveTint: Color
    
    // View Properties
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .foregroundColor(status ? activeTint : inActiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                        // Only Visible When Status is Active
                            .opacity(status ? 1: 0)
                        // Making Base Visibiliti With Zero Animation
                            .animation(.none, value: status)
                    }
                }
                .onAppear{
                    // Adding Base Particles For Animation
                    if particles.isEmpty {
                        // Change Count as per your wish
                        for _ in 1...15 {
                            /* Мы вводим некоторые частицы для анимации, поскольку массив
                             частиц теперь пуст, его размер можно изменить в соответствии с вашими потребностями.
                             */
                            let particle = Particle()
                            particles.append(particle)
                        }
                    }
                }
                .onChange(of: status) { newValue in
                    if !newValue {
                        // Reset Animation
                        for index in particles.indices {
                            particles[index].reset()
                        }
                    } else {
                        // Activating Particles
                        for index in particles.indices {
                            // Random X & Y Calculation Based on Index
                            let total: CGFloat = CGFloat(particles.count)
                            let progress: CGFloat = CGFloat(index) / total
                            
                            let maxX: CGFloat = (progress > 0.5) ? 100 : -100
                            let maxY: CGFloat = 60
                            
                            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
                            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY) + 35
                            /*
                             Вместо того, чтобы использовать случайные значения для анимации, мы собираемся использовать индекс частиц для генерации случайных значений. Таким образом, когда прогресс превысит 0,5, все частицы будут размещены справа, а все остальное
                             - слева, создавая таким образом V-образное положение. Затем мы можем дополнительно добавить случайные значения для более приятной анимации положения.
                             */
                            // Min Scale = 0.35
                            // Max Scale = 1
                            let randomScale: CGFloat = .random(in: 0.35...1)
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                // Extra Random Values For Spreading Particles Across the View
                                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                                let extraRandomY: CGFloat = .random(in: 0...30)
                                
                                particles[index].randomX = randomX + extraRandomX
                                particles[index].randomY = -randomY - extraRandomY
                            }
                            
                            // Scaling With Ease Animation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                particles[index].scale = randomScale
                            }
                            
                            // Removing Particles Based on Index
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)
                                .delay(0.25 + (Double(index) * 0.005))){
                                    particles[index].scale = 0.001
                                }
                        }
                    }
                }
            }
    }
}
