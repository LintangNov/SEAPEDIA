import { PrismaClient, OrderStatus, DeliveryMethod, TransactionType, DiscountType } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting seed execution...');

  // 1. Seeding master roles
  const roles = ['ADMIN', 'SELLER', 'BUYER', 'DRIVER'];
  for (const roleName of roles) {
    await prisma.role.upsert({
      where: { name: roleName },
      update: {},
      create: { name: roleName },
    });
  }
  console.log('✓ Seeding master roles done');

  // Helper for password hashing
  const saltRounds = 10;
  const hashPassword = async (pwd: string) => await bcrypt.hash(pwd, saltRounds);

  // 2. Seeding Users
  const userPasswords = 'password123';
  const superadminPassword = 'adminpassword123';

  // Admin user
  const adminUser = await prisma.user.upsert({
    where: { username: 'superadmin' },
    update: {},
    create: {
      username: 'superadmin',
      email: 'admin@seapedia.com',
      phoneNumber: '081234567890',
      passwordHash: await hashPassword(superadminPassword),
      roles: {
        create: { role: { connect: { name: 'ADMIN' } } }
      }
    }
  });
  console.log('✓ Seeding Admin account done');

  // Buyer user
  const buyerUser1 = await prisma.user.upsert({
    where: { username: 'buyer1' },
    update: {},
    create: {
      username: 'buyer1',
      email: 'buyer1@seapedia.com',
      phoneNumber: '081111111111',
      passwordHash: await hashPassword(userPasswords),
      roles: {
        create: { role: { connect: { name: 'BUYER' } } }
      },
      buyerProfile: {
        create: {
          walletBalance: 500000.00,
          deliveryAddress: 'Jl. Samudera Raya No. 100, Jakarta Selatan'
        }
      }
    }
  });

  // Sellers
  const sellerUser1 = await prisma.user.upsert({
    where: { username: 'seller1' },
    update: {},
    create: {
      username: 'seller1',
      email: 'seller1@seapedia.com',
      phoneNumber: '082222222222',
      passwordHash: await hashPassword(userPasswords),
      roles: {
        create: { role: { connect: { name: 'SELLER' } } }
      },
      sellerProfile: {
        create: {
          storeName: 'Aqua Marine Shop'
        }
      }
    }
  });

  const sellerUser2 = await prisma.user.upsert({
    where: { username: 'seller2' },
    update: {},
    create: {
      username: 'seller2',
      email: 'seller2@seapedia.com',
      phoneNumber: '083333333333',
      passwordHash: await hashPassword(userPasswords),
      roles: {
        create: { role: { connect: { name: 'SELLER' } } }
      },
      sellerProfile: {
        create: {
          storeName: 'Deep Blue Coral'
        }
      }
    }
  });

  // Driver
  const driverUser1 = await prisma.user.upsert({
    where: { username: 'driver1' },
    update: {},
    create: {
      username: 'driver1',
      email: 'driver1@seapedia.com',
      phoneNumber: '084444444444',
      passwordHash: await hashPassword(userPasswords),
      roles: {
        create: { role: { connect: { name: 'DRIVER' } } }
      },
      driverProfile: {
        create: {
          earnings: 0.00
        }
      }
    }
  });

  // Multi-role user (Buyer, Seller, Driver)
  const multiUser = await prisma.user.upsert({
    where: { username: 'multi_user' },
    update: {},
    create: {
      username: 'multi_user',
      email: 'multiuser@seapedia.com',
      phoneNumber: '085555555555',
      passwordHash: await hashPassword(userPasswords),
      roles: {
        create: [
          { role: { connect: { name: 'BUYER' } } },
          { role: { connect: { name: 'SELLER' } } },
          { role: { connect: { name: 'DRIVER' } } },
        ]
      },
      buyerProfile: {
        create: {
          walletBalance: 250000.00,
          deliveryAddress: 'Jl. Terumbu Karang No. 7, Jakarta Utara'
        }
      },
      sellerProfile: {
        create: {
          storeName: 'Multi Ocean Store'
        }
      },
      driverProfile: {
        create: {
          earnings: 0.00
        }
      }
    }
  });
  console.log('✓ Seeding Users and Role Profiles done');

  // 3. Seeding Products (belongs to stores/sellers)
  const p1 = await prisma.product.create({
    data: {
      name: 'Ikan Badut Hias (Clownfish)',
      description: 'Ikan hias laut nemo sehat aktif makan rakus.',
      price: 50000.00,
      stock: 15,
      sellerId: sellerUser1.id
    }
  });

  const p2 = await prisma.product.create({
    data: {
      name: 'Coral Anemon Merah',
      description: 'Anemon laut merah segar cocok untuk rumah nemo.',
      price: 120000.00,
      stock: 5,
      sellerId: sellerUser1.id
    }
  });

  const p3 = await prisma.product.create({
    data: {
      name: 'Rumput Laut Asin Kering',
      description: 'Rumput laut alami bergaram untuk pakan atau cemilan.',
      price: 25000.00,
      stock: 30,
      sellerId: sellerUser2.id
    }
  });

  const p4 = await prisma.product.create({
    data: {
      name: 'Pakan Ikan Laut Premium',
      description: 'Mengandung protein tinggi mempercepat pertumbuhan ikan hias air asin.',
      price: 35000.00,
      stock: 50,
      sellerId: multiUser.id
    }
  });
  console.log('✓ Seeding Products done');

  // 4. Seeding Discounts
  const discountVoucher = await prisma.discount.create({
    data: {
      code: 'VOUCHER10',
      type: DiscountType.VOUCHER,
      amount: 10000.00,
      expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
      remainingUsage: 10
    }
  });

  const discountPromo = await prisma.discount.create({
    data: {
      code: 'PROMO50',
      type: DiscountType.PROMO,
      amount: 50000.00,
      expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    }
  });

  const expiredPromo = await prisma.discount.create({
    data: {
      code: 'EXPIRED20',
      type: DiscountType.PROMO,
      amount: 20000.00,
      expiryDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // expired 5 days ago
    }
  });
  console.log('✓ Seeding Discounts done');

  // 5. Seeding Application Reviews
  await prisma.applicationReview.createMany({
    data: [
      {
        reviewerName: 'Alice Johnson',
        rating: 5,
        comment: 'SEAPEDIA sangat mempermudah pemesanan biota laut, UI-nya segar sekali!',
      },
      {
        reviewerName: 'Budi Santoso',
        rating: 4,
        comment: 'Pengirimannya cepat dengan metode Instant. Rekomendasi belanja.',
      }
    ]
  });
  console.log('✓ Seeding Application Reviews done');

  // 6. Seeding Carts (with items)
  const cartBuyer1 = await prisma.cart.create({
    data: {
      buyerId: buyerUser1.id,
      sellerId: sellerUser1.id,
      items: {
        create: {
          productId: p1.id,
          quantity: 2
        }
      }
    }
  });
  console.log('✓ Seeding Cart done');

  // 7. Seeding Orders and related transaction histories
  // Order 1: Completed Order (shows driver earning and reports)
  const o1 = await prisma.order.create({
    data: {
      buyerId: buyerUser1.id,
      sellerId: sellerUser1.id,
      subtotal: 100000.00, // 2 x Clownfish (50,000)
      discountAmount: 0.00,
      deliveryFee: 20000.00, // INSTANT
      taxAmount: 12000.00, // 12% of 100,000
      finalTotal: 132000.00,
      deliveryMethod: DeliveryMethod.INSTANT,
      status: OrderStatus.ORDER_COMPLETED,
      items: {
        create: {
          productId: p1.id,
          quantity: 2,
          priceAtPurchase: 50000.00
        }
      },
      statusHistory: {
        create: [
          { status: OrderStatus.BEING_PACKED, createdAt: new Date(Date.now() - 2 * 3600 * 1000) },
          { status: OrderStatus.AWAITING_SHIPMENT, createdAt: new Date(Date.now() - 1.5 * 3600 * 1000) },
          { status: OrderStatus.BEING_SHIPPED, createdAt: new Date(Date.now() - 1.0 * 3600 * 1000) },
          { status: OrderStatus.ORDER_COMPLETED, createdAt: new Date(Date.now() - 0.5 * 3600 * 1000) },
        ]
      },
      deliveryJob: {
        create: {
          driverId: driverUser1.id,
          pickedUpAt: new Date(Date.now() - 1.0 * 3600 * 1000),
          completedAt: new Date(Date.now() - 0.5 * 3600 * 1000)
        }
      }
    }
  });

  // Deduct Buyer wallet balance & add history transaction for Order 1
  await prisma.buyerProfile.update({
    where: { userId: buyerUser1.id },
    data: { walletBalance: { decrement: 132000.00 } }
  });

  await prisma.walletTransaction.create({
    data: {
      buyerId: buyerUser1.id,
      amount: 132000.00,
      type: TransactionType.CHECKOUT,
      description: 'Pemesanan Clownfish Hias (Instant)',
      createdAt: new Date(Date.now() - 2 * 3600 * 1000)
    }
  });

  // Credit driver earnings
  await prisma.driverProfile.update({
    where: { userId: driverUser1.id },
    data: { earnings: { increment: 20000.00 } }
  });

  // Order 2: Order awaiting shipment (available in Driver Job search pool)
  const o2 = await prisma.order.create({
    data: {
      buyerId: buyerUser1.id,
      sellerId: sellerUser2.id,
      subtotal: 50000.00, // 2 x Rumput Laut (25,000)
      discountAmount: 0.00,
      deliveryFee: 10000.00, // REGULAR
      taxAmount: 6000.00, // 12% of 50,000
      finalTotal: 66000.00,
      deliveryMethod: DeliveryMethod.REGULAR,
      status: OrderStatus.AWAITING_SHIPMENT,
      items: {
        create: {
          productId: p3.id,
          quantity: 2,
          priceAtPurchase: 25000.00
        }
      },
      statusHistory: {
        create: [
          { status: OrderStatus.BEING_PACKED, createdAt: new Date(Date.now() - 1 * 3600 * 1000) },
          { status: OrderStatus.AWAITING_SHIPMENT, createdAt: new Date(Date.now() - 0.5 * 3600 * 1000) }
        ]
      }
    }
  });

  await prisma.buyerProfile.update({
    where: { userId: buyerUser1.id },
    data: { walletBalance: { decrement: 66000.00 } }
  });

  await prisma.walletTransaction.create({
    data: {
      buyerId: buyerUser1.id,
      amount: 66000.00,
      type: TransactionType.CHECKOUT,
      description: 'Pemesanan Rumput Laut Asin Kering (Regular)',
      createdAt: new Date(Date.now() - 1 * 3600 * 1000)
    }
  });

  console.log('✓ Seeding Orders, status history, wallet transactions, and delivery jobs done');
  console.log('=========================================');
  console.log('Database Seeding successfully completed without orphans!');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });