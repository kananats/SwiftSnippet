//
//  add_vectors.metal
//  TestMetal
//
//  Created by Kananat Suwanviwatana on 2019/01/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_vectors(const device float *inA [[buffer(0)]],
            const device float *inB [[buffer(1)]],
            device float *out [[buffer(2)]],
            uint id [[thread_position_in_grid]]
)
{
    out[id] = inA[id] + inB[id];
}
