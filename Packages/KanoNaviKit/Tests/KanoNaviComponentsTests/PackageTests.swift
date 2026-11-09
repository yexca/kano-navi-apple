import Testing

@testable import KanoNaviComponents

struct PackageTests {
    @Test @MainActor func componentsModuleLoads() {
        #expect(String(describing: KanoNaviComponents.self) == "KanoNaviComponents")
    }
}
