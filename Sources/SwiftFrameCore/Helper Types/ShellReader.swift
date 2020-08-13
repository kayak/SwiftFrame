import Foundation

public struct ShellReader {

    public static func readString(with promptText: String, strippingNewline: Bool = true) -> String? {
        print(promptText) // swiftlint:disable:this no_print
        return readLine(strippingNewline: strippingNewline)
    }

    public static func confirmQuestion(_ question: String) -> Bool {
        print(question, "[Y/N]:") // swiftlint:disable:this no_print
        let result = readLine(strippingNewline: true)
        switch result?.lowercased() {
        case "y":
            return true
        case "n":
            return false
        default:
            print("Invalid input, defaulting to false") // swiftlint:disable:this no_print
            return false
        }
    }

    public static func promptUserForChoice(menuTitle: String, choices: [String]) -> Int {
        // swiftlint:disable no_print
        print(menuTitle)

        choices.enumerated().forEach {
            print("\($0.offset + 1). \($0.element)")
        }

        var choiceIndex: Int?
        while choiceIndex == nil {
            guard let input = readString(with: "Please enter a number associated with a choice:") else {
                continue
            }
            guard let integerInput = Int(input) else {
                print("You did not enter a valid number")
                continue
            }

            if choices.indices.contains(integerInput - 1) {
                choiceIndex = integerInput - 1
            } else {
                print("No choice associated with your input")
            }
        }

        guard let index = choiceIndex else {
            fatalError("Somehow exited loop without finding a valid integer")
        }
        return index
        // swiftlint:enable no_print
    }

}
