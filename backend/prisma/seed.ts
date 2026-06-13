import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {

    // master roles
    const roles = ['ADMIN', 'SELLER', 'BUYER', 'DRIVER'];

    for (const roleName of roles) {
        await prisma.role.upsert({
            where: { name: roleName },
            update: {},
            create: { name: roleName },
        });
    }
    console.log('Role tables seeding done');

    // super admin account
    const adminUsername = 'superadmin';
    const adminPassword = 'adminpassword123';
    const saltRounds = 10;

    const hashedPassword = await bcrypt.hash(adminPassword, saltRounds);

    await prisma.user.upsert({
        where: { username: adminUsername },
        update: {},
        create: {
            username: adminUsername,
            passwordHash: hashedPassword,
            roles: {
                create: {
                    role: {
                        connect: { name: 'ADMIN' },
                    },
                },
            },
        },
    });
    console.log(`Super Admin account seeding done (Username: ${adminUsername})`);
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
}).finally(async () =>{
    await prisma.$disconnect();
});