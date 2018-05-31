//
//  NSDictionary+RuntimeObjectForKey.m
//  Method_exchange
//
//  Created by L on 2018/5/31.
//  Copyright © 2018年 L. All rights reserved.
//

#import "NSDictionary+RuntimeObjectForKey.h"
#import <objc/runtime.h>

@implementation NSDictionary (RuntimeObjectForKey)

+ (void) load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // 选择器
        SEL originalSEL = @selector(objectForKey:);//@selector(objectForKey:);
        SEL SwizzledSEL = @selector(hObjectForKey:);
        
        
        //          方法    使用NSDictionary、NSArray，必须使用与其对应的加入内存时的元类
        //       __NSDictionaryI——NSDictionary   __NSDictionaryM——NSMutableDictionary
        //       __NSArrayI——NSArray             __NSArrayM——NSMutableArray
        Method originalMethod = class_getInstanceMethod(NSClassFromString(@"__NSDictionaryI"), originalSEL);//class_getClassMethod(class, originalSEL);备注的是获取静态方法
        Method SwizzledMethod = class_getInstanceMethod(NSClassFromString(@"__NSDictionaryI"), SwizzledSEL);//class_getClassMethod(class, SwizzledSEL);
        
        // 方法的实现
        IMP originalIMP = method_getImplementation(originalMethod);//class_getMethodImplementation(class, originalSEL);
        IMP SwizzledIMP = method_getImplementation(SwizzledMethod);//class_getMethodImplementation(class, SwizzledSEL);
        
        
        // 是否添加成功方法:添加了初始方法，实现内容指向目标方法体
        BOOL isSuccess = class_addMethod(class, originalSEL, SwizzledIMP, method_getTypeEncoding(SwizzledMethod));
        
        if (isSuccess) {
            // 初始指向目标，那么把目标的内容指向初始
            class_replaceMethod(class, SwizzledSEL, originalIMP, method_getTypeEncoding(originalMethod));
        }
        else{
            // 没有添加成功说明已经存在，就交换
            // 注意，这里交换的是IMP 实现
            method_exchangeImplementations(originalMethod, SwizzledMethod);
        }
        
    });
}

- (id)hObjectForKey:(id)aKey{
    id value = [self hObjectForKey:aKey];
    NSLog(@"走了");
    return value;
}

@end
