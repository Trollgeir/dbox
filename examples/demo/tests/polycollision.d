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
module tests.polycollision;

import core.stdc.math;

import std.string;
import std.typecons;

import deimos.glfw.glfw3;

import dbox;

import framework.debug_draw;
import framework.test;

class PolyCollision : Test
{
    this()
    {
        m_polygonA = new b2PolygonShape();
        m_polygonB = new b2PolygonShape();

        {
            m_polygonA.SetAsBox(0.2f, 0.4f);
            m_transformA.Set(b2Vec2(0.0f, 0.0f), 0.0f);
        }

        {
            m_polygonB.SetAsBox(0.5f, 0.5f);
            m_positionB.Set(19.345284f, 1.5632932f);
            m_angleB = 1.9160721f;
            m_transformB.Set(m_positionB, m_angleB);
        }
    }

    override void Step(Settings* settings)
    {
        super.Step(settings);

        b2Manifold manifold;
        b2CollidePolygons(&manifold, m_polygonA, m_transformA, m_polygonB, m_transformB);

        b2WorldManifold worldManifold;
        worldManifold.Initialize(&manifold, m_transformA, m_polygonA.m_radius, m_transformB, m_polygonB.m_radius);

        g_debugDraw.DrawString(5, m_textLine, format("point count = %d", manifold.pointCount));
        m_textLine += DRAW_STRING_NEW_LINE;

        {
            b2Color color = b2Color(0.9f, 0.9f, 0.9f);
            b2Vec2  v[b2_maxPolygonVertices];

            for (int32 i = 0; i < m_polygonA.m_count; ++i)
            {
                v[i] = b2Mul(m_transformA, m_polygonA.m_vertices[i]);
            }

            g_debugDraw.DrawPolygon(v.ptr, m_polygonA.m_count, color);

            for (int32 i = 0; i < m_polygonB.m_count; ++i)
            {
                v[i] = b2Mul(m_transformB, m_polygonB.m_vertices[i]);
            }

            g_debugDraw.DrawPolygon(v.ptr, m_polygonB.m_count, color);
        }

        for (int32 i = 0; i < manifold.pointCount; ++i)
        {
            g_debugDraw.DrawPoint(worldManifold.points[i], 4.0f, b2Color(0.9f, 0.3f, 0.3f));
        }
    }

    override void Keyboard(int key)
    {
        switch (key)
        {
            case GLFW_KEY_A:
                m_positionB.x -= 0.1f;
                break;

            case GLFW_KEY_D:
                m_positionB.x += 0.1f;
                break;

            case GLFW_KEY_S:
                m_positionB.y -= 0.1f;
                break;

            case GLFW_KEY_W:
                m_positionB.y += 0.1f;
                break;

            case GLFW_KEY_Q:
                m_angleB += 0.1f * b2_pi;
                break;

            case GLFW_KEY_E:
                m_angleB -= 0.1f * b2_pi;
                break;

            default:
                break;
        }

        m_transformB.Set(m_positionB, m_angleB);
    }

    b2PolygonShape m_polygonA;
    b2PolygonShape m_polygonB;

    b2Transform m_transformA;
    b2Transform m_transformB;

    b2Vec2  m_positionB;
    float32 m_angleB = 0;

    static Test Create()
    {
        return new typeof(this);
    }
}
