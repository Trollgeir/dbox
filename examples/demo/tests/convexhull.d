/*
 * Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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
module tests.convexhull;

import core.stdc.math;

import std.algorithm;
import std.string;
import std.typecons;

import deimos.glfw.glfw3;

import dbox;

import framework.debug_draw;
import framework.test;

class ConvexHull : Test
{
    enum
    {
        e_count = b2_maxPolygonVertices
    }


    this()
    {
        Generate();
        m_auto = false;
    }

    void Generate()
    {
        b2Vec2 lowerBound = b2Vec2(-8.0f, -8.0f);
        b2Vec2 upperBound = b2Vec2(8.0f, 8.0f);

        for (int32 i = 0; i < e_count; ++i)
        {
            float32 x = 10.0f * RandomFloat();
            float32 y = 10.0f * RandomFloat();

            // Clamp onto a square to help create collinearities.
            // This will stress the convex hull algorithm.
            b2Vec2 v = b2Vec2(x, y);
            v = b2Clamp(v, lowerBound, upperBound);
            m_points[i] = v;
        }

        m_count = e_count;
    }

    override void Keyboard(int key)
    {
        switch (key)
        {
            case GLFW_KEY_A:
                m_auto = !m_auto;
                break;

            case GLFW_KEY_G:
                Generate();
                break;

            default:
                break;
        }
    }

    override void Step(Settings* settings)
    {
        Test.Step(settings);

        auto shape = new b2PolygonShape();
        shape.Set(m_points[0 .. m_count]);

        g_debugDraw.DrawString(5, m_textLine, "Press g to generate a new random convex hull");
        m_textLine += DRAW_STRING_NEW_LINE;

        g_debugDraw.DrawPolygon(shape.m_vertices.ptr, shape.m_count, b2Color(0.9f, 0.9f, 0.9f));

        for (int32 i = 0; i < m_count; ++i)
        {
            g_debugDraw.DrawPoint(m_points[i], 3.0f, b2Color(0.3f, 0.9f, 0.3f));
            g_debugDraw.DrawString(m_points[i] + b2Vec2(0.05f, 0.05f), format("%d", i));
        }

        if (shape.Validate() == false)
        {
            m_textLine += 0;
        }

        if (m_auto)
        {
            Generate();
        }
    }

    static Test Create()
    {
        return new typeof(this);
    }

    b2Vec2 m_points[b2_maxPolygonVertices];
    int32  m_count;
    bool m_auto;
}
