/*
 * Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */
module dbox.common;

import std.conv;

template getSizeOf(T) if (is(T == class))
{
    enum getSizeOf = __traits(classInstanceSize, T);
}

template getSizeOf(T) if (!is(T == class))
{
    enum getSizeOf = T.sizeof;
}

T emplace(T)(void* chunk) if (is(T == class))
{
    return std.conv.emplace!T(chunk[0 .. getSizeOf!T]);
}

T* emplace(T)(void* chunk) if (!is(T == class))
{
    return std.conv.emplace!T(chunk[0 .. getSizeOf!T]);
}

T emplace(T, Args...)(void* chunk, Args args) if (is(T == class))
{
    return std.conv.emplace!T(chunk[0 .. getSizeOf!T], args);
}

T* emplace(T, Args...)(void* chunk, Args args) if (!is(T == class))
{
    return std.conv.emplace!T(chunk[0 .. getSizeOf!T], args);
}

/**
    Export all enum members as aliases. This allows enums to be used as types
    and allows its members to be used as if they're defined in module scope.
*/
mixin template _ExportEnumMembers(E) if (is(E == enum))
{
    mixin(_makeEnumAliases!(E)());
}

/// ditto
string _makeEnumAliases(E)() if (is(E == enum))
{
    import std.array;
    import std.string;

    enum enumName = __traits(identifier, E);
    Appender!(string[]) result;

    foreach (string member; __traits(allMembers, E))
        result ~= format("alias %s = %s.%s;", member, enumName, member);

    return result.data.join("\n");
}

public
{
    import dbox.common.b2blockallocator;
    import dbox.common.b2draw;
    import dbox.common.b2growablestack;
    import dbox.common.b2math;
    import dbox.common.b2settings;
    import dbox.common.b2stackallocator;
    import dbox.common.b2timer;
}
