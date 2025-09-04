'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/container'
import Image from 'next/image'

interface MonitoringProps {
  language: 'ko' | 'en'
}

export function Monitoring({ language }: MonitoringProps) {
  const content = {
    ko: {
      title: (
        <>
          집에서 시작하는 전문적인<br />
          척추 모니터링
        </>
      ),
      subtitle: '아이의 척추 건강은 초기부터 꾸준히 살펴보는 것이 가장 중요합니다. 스콜리오스캔은 집에서 간단히 촬영한 사진을 AI가 분석하고, 그 결과를 전문의가 검토하여 정기적으로 관리할 수 있도록 돕습니다. 이제 병원에 자주 가지 않아도, 집과 병원이 연결된 새로운 방식의 척추 관리를 경험할 수 있습니다.'
    },
    en: {
      title: (
        <>
          Professional Spinal Monitoring<br />
          Starting at Home
        </>
      ),
      subtitle: 'Monitoring your child\'s spinal health consistently from an early stage is most important. Scoliscan helps AI analyze photos taken simply at home, with specialists reviewing the results for regular management. Now you can experience a new way of spinal care that connects home and hospital without frequent hospital visits.'
    }
  }

  return (
    <div className="h-full flex items-center justify-center bg-gray-50 relative overflow-hidden">
      {/* 배경 도형 - 섹션의 80% 높이, 90% 너비로 오른쪽에서 시작 */}
      <motion.div
        initial={{ x: '50vw', opacity: 0 }}
        whileInView={{ x: 0, opacity: 1 }}
        transition={{ duration: 0.8, delay: 0.2 }}
        className="absolute bottom-[0%] right-0 gradient-primary rounded-tl-[300px]"
        style={{ 
          height: '90%', 
          width: '90%',
          zIndex: 1
        }}
      />

      <Container size="1600">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-16 items-center relative z-10">
          {/* 텍스트 콘텐츠 - 왼쪽 하단 */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="space-y-6 lg:self-end lg:pb-16 p-20"
          >
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white leading-tight">
              {content[language].title}
            </h2>
            <p className="text-base md:text-lg text-white leading-relaxed">
              {content[language].subtitle}
            </p>
          </motion.div>

          {/* 이미지 영역 - 오른쪽 */}
          <div className="relative lg:h-[600px] h-[400px] overflow-visible">

            {/* PC 이미지 - sec6-pc (오른쪽에서 순차적으로 나옴, 일부가 오른쪽으로 걸쳐나감) */}
            <motion.div
              initial={{ x: 400, opacity: 0 }}
              whileInView={{ x: 0, opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="absolute top-4 left-0 w-[1100px] h-[680px]"
            >
              <Image
                src="/images/sec6-pc.png"
                alt="PC Interface"
                fill
                className="object-contain"
              />
            </motion.div>

            {/* 앱 이미지 - sec6-app (오른쪽에서 순차적으로 나옴) */}
            <motion.div
              initial={{ x: 300, opacity: 0 }}
              whileInView={{ x: 0, opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.6 }}
              className="absolute top-24 left-72 w-[600px] h-[850px]"
              style={{ zIndex: 30 }}
            >
              <Image
                src="/images/sec6-app.png"
                alt="Mobile App"
                fill
                className="object-contain"
              />
            </motion.div>
          </div>
        </div>
      </Container>
    </div>
  )
}