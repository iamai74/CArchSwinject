//
//  LayoutAssemblyFactory.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Community Arch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CArch
import Swinject

/// Фабрика создания и внедрение зависимости
public final class LayoutAssemblyFactory: LayoutDIAssemblyFactory {    
    
    static var provider = SwinjectProvider(.init())
    
    public var layoutContainer: DIContainer {
        Self.provider.container
    }
    
    public var registrar: DIRegistrar {
        Self.provider.container
    }
    
    public var resolver: DIResolver {
        Self.provider.container
    }
    
    public init() {}
    
    public func assembly<Module>(_ module: Module) -> Module where Module: LayoutModuleAssembly {
        Self.provider.apply(LayoutModuleApplying(module))
        return module
    }
    
    public func record<Recorder>(_ recorder: Recorder.Type) where Recorder: ServicesRecorder {
        recorder.init().all.forEach { Self.provider.apply(ServicesApplying($0)) }
    }
}

// MARK: - LayoutAssemblyFactory + Resolver
extension LayoutAssemblyFactory {
    
    /// <#Description#>
    public struct Resolver<Assembly> where Assembly: AnyObject, Assembly: LayoutModuleAssembly {
        
        public typealias Weak = StorageType.WeakReference<Assembly>
        
        /// <#Description#>
        private let reference: Weak
        /// <#Description#>
        private let factory: LayoutAssemblyFactory
        
        /// <#Description#>
        /// - Parameter factory: <#factory description#>
        public init(factory: LayoutAssemblyFactory) {
            self.factory = factory
            self.reference = .init(factory.assembly(Assembly()))
        }
        
        /// <#Description#>
        /// - Parameter moduleType: <#moduleType description#>
        /// - Returns: <#description#>
        public func unravel<Module>(_ moduleType: Module.Type) -> Module where Module: CArchModule {
            guard
                let module = factory.resolver.unravel(moduleType)
            else { preconditionFailure("Couldn't to resolve \(String(describing: Module.self))") }
            return module
        }
    }
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    public static func assembly<Module>(_ type: Module.Type) -> Resolver<Module> {
        .init(factory: .init())
    }
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    public func assembly<Module>(_ type: Module.Type) -> Resolver<Module> {
        .init(factory: self)
    }
}
