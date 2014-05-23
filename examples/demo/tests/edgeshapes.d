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
module tests.edgeshapes;

import core.stdc.math;
import core.stdc.stdlib;

import std.algorithm;
import std.string;
import std.typecons;

import deimos.glfw.glfw3;

import dbox;

import framework.debug_draw;
import framework.test;

class EdgeShapesCallback : b2RayCastCallback
{
    this()
    {
        m_fixture = null;
    }

    override float32 ReportFixture(b2Fixture* fixture, b2Vec2 point, b2Vec2 normal, float32 fraction)
    {
        m_fixture = fixture;
        m_point   = point;
        m_normal  = normal;

        return fraction;
    }

    b2Fixture* m_fixture;
    b2Vec2 m_point;
    b2Vec2 m_normal;
}

class EdgeShapes : Test
{
    enum
    {
        e_maxBodies = 256
    }

    this()
    {
        m_circle = new typeof(m_circle);

        foreach (ref poly; m_polygons)
            poly = new typeof(poly);

        // Ground body_
        {
            b2BodyDef bd;
            b2Body* ground = m_world.CreateBody(&bd);

            float32 x1 = -20.0f;
            float32 y1 = 2.0f * cosf(x1 / 10.0f * b2_pi);

            for (int32 i = 0; i < 80; ++i)
            {
                float32 x2 = x1 + 0.5f;
                float32 y2 = 2.0f * cosf(x2 / 10.0f * b2_pi);

                auto shape = new b2EdgeShape();
                shape.Set(b2Vec2(x1, y1), b2Vec2(x2, y2));
                ground.CreateFixture(shape, 0.0f);

                x1 = x2;
                y1 = y2;
            }
        }

        {
            b2Vec2 vertices[3];
            vertices[0].Set(-0.5f, 0.0f);
            vertices[1].Set(0.5f, 0.0f);
            vertices[2].Set(0.0f, 1.5f);
            m_polygons[0].Set(vertices);
        }

        {
            b2Vec2 vertices[3];
            vertices[0].Set(-0.1f, 0.0f);
            vertices[1].Set(0.1f, 0.0f);
            vertices[2].Set(0.0f, 1.5f);
            m_polygons[1].Set(vertices);
        }

        {
            float32 w = 1.0f;
            float32 b = w / (2.0f + b2Sqrt(2.0f));
            float32 s = b2Sqrt(2.0f) * b;

            b2Vec2 vertices[8];
            vertices[0].Set(0.5f * s, 0.0f);
            vertices[1].Set(0.5f * w, b);
            vertices[2].Set(0.5f * w, b + s);
            vertices[3].Set(0.5f * s, w);
            vertices[4].Set(-0.5f * s, w);
            vertices[5].Set(-0.5f * w, b + s);
            vertices[6].Set(-0.5f * w, b);
            vertices[7].Set(-0.5f * s, 0.0f);

            m_polygons[2].Set(vertices);
        }

        {
            m_polygons[3].SetAsBox(0.5f, 0.5f);
        }

        {
            m_circle.m_radius = 0.5f;
        }

        m_bodyIndex = 0;
        m_bodies[] = null;

        m_angle = 0.0f;
    }

    static Test Create()
    {
        return new typeof(this);
    }

    void Create(int32 index)
    {
        if (m_bodies[m_bodyIndex] != null)
        {
            m_world.DestroyBody(m_bodies[m_bodyIndex]);
            m_bodies[m_bodyIndex] = null;
        }

        b2BodyDef bd;

        float32 x = RandomFloat(-10.0f, 10.0f);
        float32 y = RandomFloat(10.0f, 20.0f);
        bd.position.Set(x, y);
        bd.angle = RandomFloat(-b2_pi, b2_pi);
        bd.type  = b2_dynamicBody;

        if (index == 4)
        {
            bd.angularDamping = 0.02f;
        }

        m_bodies[m_bodyIndex] = m_world.CreateBody(&bd);

        if (index < 4)
        {
            b2FixtureDef fd;
            fd.shape    = m_polygons[index];
            fd.friction = 0.3f;
            fd.density  = 20.0f;
            m_bodies[m_bodyIndex].CreateFixture(&fd);
        }
        else
        {
            b2FixtureDef fd;
            fd.shape    = m_circle;
            fd.friction = 0.3f;
            fd.density  = 20.0f;
            m_bodies[m_bodyIndex].CreateFixture(&fd);
        }

        m_bodyIndex = (m_bodyIndex + 1) % e_maxBodies;
    }

    void DestroyBody()
    {
        for (int32 i = 0; i < e_maxBodies; ++i)
        {
            if (m_bodies[i] != null)
            {
                m_world.DestroyBody(m_bodies[i]);
                m_bodies[i] = null;
                return;
            }
        }
    }

    override void Keyboard(int key)
    {
        switch (key)
        {
            case GLFW_KEY_1:
            case GLFW_KEY_2:
            case GLFW_KEY_3:
            case GLFW_KEY_4:
            case GLFW_KEY_5:
                Create(key - GLFW_KEY_1);
                break;

            case GLFW_KEY_D:
                DestroyBody();
                break;

            default:
        }
    }

    override void Step(Settings* settings)
    {
        bool advanceRay = settings.pause == 0 || settings.singleStep;

        Test.Step(settings);
        g_debugDraw.DrawString(5, m_textLine, "Press 1-5 to drop stuff");
        m_textLine += DRAW_STRING_NEW_LINE;

        float32 L = 25.0f;
        b2Vec2 point1 = b2Vec2(0.0f, 10.0f);
        b2Vec2 d = b2Vec2(L * cosf(m_angle), -L * b2Abs(sinf(m_angle)));
        b2Vec2 point2 = point1 + d;

        EdgeShapesCallback callback = new EdgeShapesCallback();
        m_world.RayCast(callback, point1, point2);

        if (callback.m_fixture)
        {
            g_debugDraw.DrawPoint(callback.m_point, 5.0f, b2Color(0.4f, 0.9f, 0.4f));

            g_debugDraw.DrawSegment(point1, callback.m_point, b2Color(0.8f, 0.8f, 0.8f));

            b2Vec2 head = callback.m_point + 0.5f * callback.m_normal;
            g_debugDraw.DrawSegment(callback.m_point, head, b2Color(0.9f, 0.9f, 0.4f));
        }
        else
        {
            g_debugDraw.DrawSegment(point1, point2, b2Color(0.8f, 0.8f, 0.8f));
        }

        if (advanceRay)
        {
            m_angle += 0.25f * b2_pi / 180.0f;
        }
    }

    int32 m_bodyIndex;
    b2Body* m_bodies[e_maxBodies];
    b2PolygonShape m_polygons[4];
    b2CircleShape  m_circle;

    float32 m_angle;
}
