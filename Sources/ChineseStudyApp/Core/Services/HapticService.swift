import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#elseif SKIP
import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
#endif

/// Types of tactile haptic feedback used throughout the app.
public enum HapticFeedbackType: String, CaseIterable, Sendable {
    case lightImpact = "lightImpact"
    case mediumImpact = "mediumImpact"
    case heavyImpact = "heavyImpact"
    case success = "success"
    case warning = "warning"
    case error = "error"
}

/// Unified cross-platform haptic feedback service.
@MainActor
public final class HapticService: Sendable {
    public static let shared = HapticService()

    #if os(iOS)
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    #endif

    private init() {
        #if os(iOS)
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        #endif
    }

    /// Triggers a vibration/haptic sensation on physical devices.
    public func trigger(_ type: HapticFeedbackType, isEnabled: Bool = true) {
        guard isEnabled else { return }

        #if os(iOS)
        switch type {
        case .lightImpact:
            lightGenerator.impactOccurred()
        case .mediumImpact:
            mediumGenerator.impactOccurred()
        case .heavyImpact:
            heavyGenerator.impactOccurred()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
        #elseif SKIP
        let appContext = ProcessInfo.processInfo.androidContext
        let vibrator: Vibrator? = if Build.VERSION.SDK_INT >= Build.VERSION_CODES.S {
            let manager = appContext.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            manager?.defaultVibrator
        } else {
            appContext.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

        guard let vib = vibrator, vib.hasVibrator() else { return }

        if Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q {
            let effect: VibrationEffect? = switch type {
            case .lightImpact:
                VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK)
            case .mediumImpact:
                VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
            case .heavyImpact:
                VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK)
            case .success:
                VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK)
            case .warning:
                VibrationEffect.createOneShot(120, 180)
            case .error:
                VibrationEffect.createWaveform(longArrayOf(0, 60, 60, 60), intArrayOf(0, 200, 0, 200), -1)
            }
            if let eff = effect {
                vib.vibrate(eff)
            }
        } else {
            vib.vibrate(50)
        }
        #endif
    }
}
