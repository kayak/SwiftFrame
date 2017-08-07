import XCTest

class BackgroundTests: XCTestCase {

    // MARK: - Gradient Direction
    
    func testGradientDirectionFromSpec() {
        XCTAssertNil(Background.GradientDirection(value: ""))
        XCTAssertNil(Background.GradientDirection(value: "top"))
        XCTAssertNil(Background.GradientDirection(value: "to top "))
        XCTAssertNil(Background.GradientDirection(value: " to top"))

        XCTAssertEqual(.toTop, Background.GradientDirection(value: "to top"))
        XCTAssertEqual(.toBottom, Background.GradientDirection(value: "to bottom"))
        XCTAssertEqual(.toLeft, Background.GradientDirection(value: "to left"))
        XCTAssertEqual(.toRight, Background.GradientDirection(value: "to right"))
        XCTAssertEqual(.toLeftTop, Background.GradientDirection(value: "to left top"))
        XCTAssertEqual(.toRightTop, Background.GradientDirection(value: "to right top"))
        XCTAssertEqual(.toLeftBottom, Background.GradientDirection(value: "to left bottom"))
        XCTAssertEqual(.toRightBottom, Background.GradientDirection(value: "to right bottom"))
    }

    // MARK: - Color Specification Parsing

    func testColorFromSpec() {
        XCTAssertThrowsError(try Background(specification: ""))
        XCTAssertThrowsError(try Background(specification: "#"))
        XCTAssertThrowsError(try Background(specification: "#FF"))
        XCTAssertThrowsError(try Background(specification: "#FFFF"))
        XCTAssertThrowsError(try Background(specification: "FFFFFF"))

        guard let background = try? Background(specification: "#FFFFFF") else {
            XCTFail()
            return
        }
        guard case .solid(let color) = background else {
            XCTFail()
            return
        }
        XCTAssertEqual("#FFFFFF", color.hexString.uppercased())
    }

    // MARK: - Linear Gradient Specification Parsing

    func testLinearGradientFromSpec() {
        XCTAssertThrowsError(try Background(specification: ""))
        XCTAssertThrowsError(try Background(specification: "linear-gradient()"))
        XCTAssertThrowsError(try Background(specification: "linear-gradient(to right)"))
        XCTAssertThrowsError(try Background(specification: "linear-gradient(#FFFFFF)"))
        XCTAssertThrowsError(try Background(specification: "linear-gradient(to right, #FFFFFF)"))
        XCTAssertThrowsError(try Background(specification: "linear-gradient(#FFFFFF, #000000)"))

        guard let background = try? Background(specification: "linear-gradient(to right, #FFFFFF, #000000)") else {
            XCTFail()
            return
        }
        guard case .linearGradient(let direction, let colors) = background else {
            XCTFail()
            return
        }
        XCTAssertEqual(.toRight, direction)
        XCTAssertEqual(["#FFFFFF", "#000000"], colors.map({ $0.hexString.uppercased() }))
    }
    
}
