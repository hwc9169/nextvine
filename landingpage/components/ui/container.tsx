import { cn } from '@/lib/utils'
import { ReactNode } from 'react'

interface ContainerProps {
  children: ReactNode
  className?: string
  size?: 'sm' | 'md' | 'lg' | 'xl' | '1600' | 'full'
}

export function Container({ 
  children, 
  className, 
  size = 'xl' 
}: ContainerProps) {
  return (
    <div
      className={cn(
        'mx-auto px-4 sm:px-6 lg:px-8',
        {
          'max-w-3xl': size === 'sm',
          'max-w-4xl': size === 'md',
          'max-w-6xl': size === 'lg',
          'max-w-7xl': size === 'xl',
          'max-w-[1600px]': size === '1600',
          'max-w-none': size === 'full',
        },
        className
      )}
    >
      {children}
    </div>
  )
}