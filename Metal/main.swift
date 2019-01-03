//
//  main.swift
//  TestMetal
//
//  Created by Kananat Suwanviwatana on 2019/01/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import MetalKit

func add_vectors_sync(_ vec1: [Float], _ vec2: [Float]) -> [Float] {
    let device = MTLCreateSystemDefaultDevice()!
    let library = device.makeDefaultLibrary()!
    
    let function = library.makeFunction(name: "add_vectors")!
    let pipelineState = try! device.makeComputePipelineState(function: function)
    
    let commandQueue = device.makeCommandQueue()!
    let commandBuffer = commandQueue.makeCommandBuffer()!
    
    let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
    commandEncoder.setComputePipelineState(pipelineState)
    
    let count = max(vec1.count, vec2.count)
    
    let buffer0 = device.makeBuffer(bytes: vec1, length: vec1.count * MemoryLayout<Float>.stride)!
    let buffer1 = device.makeBuffer(bytes: vec2, length: vec2.count * MemoryLayout<Float>.stride)!
    
    // Error when count < 4
    let buffer2 = device.makeBuffer(length: max(count, 4))!
    
    commandEncoder.setBuffer(buffer0, offset: 0, index: 0)
    commandEncoder.setBuffer(buffer1, offset: 0, index: 1)
    commandEncoder.setBuffer(buffer2, offset: 0, index: 2)

    let threadgroupsPerGrid = MTLSize(width: 1, height: 1, depth: 1)
    let threadsPerThreadgroup = MTLSize(width: pipelineState.threadExecutionWidth, height: 1, depth: 1)
    
    commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    commandEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    
    let array = Array(UnsafeBufferPointer(start: buffer2.contents().assumingMemoryBound(to: Float.self), count: count))
    
    return array
}

func add_vectors_async(_ vec1: [Float], _ vec2: [Float], completion: @escaping ([Float]) -> ()) {
    let device = MTLCreateSystemDefaultDevice()!
    let library = device.makeDefaultLibrary()!
    
    let function = library.makeFunction(name: "add_vectors")!
    let pipelineState = try! device.makeComputePipelineState(function: function)
    
    let commandQueue = device.makeCommandQueue()!
    let commandBuffer = commandQueue.makeCommandBuffer()!
    
    let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
    commandEncoder.setComputePipelineState(pipelineState)
    
    let count = max(vec1.count, vec2.count)
    
    let buffer0 = device.makeBuffer(bytes: vec1, length: vec1.count * MemoryLayout<Float>.stride)!
    let buffer1 = device.makeBuffer(bytes: vec2, length: vec2.count * MemoryLayout<Float>.stride)!
    
    // Error when count < 4
    let buffer2 = device.makeBuffer(length: max(count, 4))!
    
    commandEncoder.setBuffer(buffer0, offset: 0, index: 0)
    commandEncoder.setBuffer(buffer1, offset: 0, index: 1)
    commandEncoder.setBuffer(buffer2, offset: 0, index: 2)
    
    let threadgroupsPerGrid = MTLSize(width: 1, height: 1, depth: 1)
    let threadsPerThreadgroup = MTLSize(width: pipelineState.threadExecutionWidth, height: 1, depth: 1)
    
    commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    commandEncoder.endEncoding()
    
    commandBuffer.addCompletedHandler { value in
        let array = Array(UnsafeBufferPointer(start: buffer2.contents().assumingMemoryBound(to: Float.self), count: count))
        
        completion(array)
    }
    
    commandBuffer.commit()
}

func main() {
    let vec1: [Float] = [1, 2, 3, 8, 9, 10, 8, 9, 10]
    let vec2: [Float] = [5, 6, 7, 8, 9, 10]
    
    add_vectors_async(vec1, vec2) {
        print($0) // [6.0, 8.0, 10.0, 16.0, 18.0, 20.0, 8.0, 9.0, 10.0]
    }
    
    print(add_vectors_sync(vec1, vec2)) // [6.0, 8.0, 10.0, 16.0, 18.0, 20.0, 8.0, 9.0, 10.0]
}

main()
// foo()

print("Program finished")
while(true) { }
